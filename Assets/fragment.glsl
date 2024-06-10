#version 300 es
precision highp float;

in vec4 vertColor;
in vec2 texCoord;
in vec3 normal;
in vec3 fragPos;
in vec3 tangentLightDir;
in vec3 tangentViewPos;
in vec3 tangentFragPos;
in vec4 dirLightSpacePos;

out vec4 color;

const int MAX_POINT_LIGHTS = 3;
const int MAX_SPOT_LIGHTS = 3;

struct Light {
	vec3 color;
	float ambientIntensity;
	float diffIntensity;
};

struct DirectionalLight {
	Light base;
	vec3 direction;
};

struct PointLight {
	Light base;
	vec3 position;
	float exponent;
	float linear;
	float constant;
};

struct SpotLight {
	PointLight base;
	vec3 direction;
	float edge;
};

struct Material {
	float specularIntensity;
	float shininess;
};

uniform int pointLightCount;
uniform int spotLightCount;

uniform DirectionalLight directionalLight;
uniform PointLight pointLights[MAX_POINT_LIGHTS];
uniform SpotLight spotLights[MAX_SPOT_LIGHTS];

uniform sampler2D diffuseTexture;
uniform sampler2D normalTexture;
uniform highp sampler2DShadow dirShadowMapTexture;

uniform Material material;

uniform vec3 camPosition;

float calcDirShadowFactorPCF(DirectionalLight light) {
	
	vec3 projCoords = dirLightSpacePos.xyz / dirLightSpacePos.w;
	projCoords = (projCoords * 0.5) + 0.5;
	
	// clamp to border replacement
	bool outRange = projCoords.x < 0.0 || projCoords.x > 1.0 || projCoords.y < 0.0 || projCoords.y > 1.0;
	
	float shadow = 0.0;
	
	if (!outRange) {
		
		vec3 normalizedNormal = normalize(normal);
		vec3 normalizedLightDir = normalize(light.direction);
		
		// float bias = max(0.01 * (1.0 - dot(normalizedNormal, normalizedLightDir)), 0.005);
		float bias = 0.001;
		float current = projCoords.z;
		vec2 texelSize = 1.0 / vec2(textureSize(dirShadowMapTexture, 0));
		
		for (int x = -1; x < 2; x++) {
			for (int y = -1; y < 2; y++) {
				
				// float pcfDepth = texture(dirShadowMapTexture, projCoords.xy + vec2(x, y) * texelSize).r;
				// shadow += current - bias > pcfDepth ? 1.0 : 0.0;
			}
		}
		
		shadow /= 9.0;
		
		// for (int x = -2; x < 3; x++) {
		// 	for (int y = -2; y < 3; y++) {
				
		// 		float pcfDepth = texture(dirShadowMapTexture, projCoords.xy + vec2(x, y) * texelSize).r;
		// 		shadow += current - bias > pcfDepth ? 1.0 : 0.0;
		// 	}
		// }
		
		// shadow /= 25.0;
	}
	
	return shadow;
}

float calcDirShadowFactor(DirectionalLight light) {
	
	vec3 projCoords = dirLightSpacePos.xyz / dirLightSpacePos.w;
	projCoords = (projCoords * 0.5) + 0.5;
	
	float bias = 0.002;
	float shadow = 1.0 - texture(dirShadowMapTexture, vec3(projCoords.xy, projCoords.z - bias));
	
	return shadow;
}

vec4 calcLightByDirection(Light light, vec3 direction, float shadowFactor) {
	
	vec3 normalizedNormal = normalize(normal);
	vec4 ambientColor = vec4(light.color, 1.0f) * light.ambientIntensity;
	
	float diffFactor = max(dot(normalizedNormal, normalize(direction)), 0.0f);
	
	vec4 diffColor = vec4(light.color, 1.0f) * light.diffIntensity * diffFactor;
	
	vec4 specularColor = vec4(0.0f, 0.0f, 0.0f, 0.0f);
	
	if (diffFactor > 0.0f) {
		
		vec3 fragToCam = normalize(camPosition - fragPos);
		vec3 reflectedVertex = normalize(reflect(-direction, normalizedNormal));
		
		float specularFactor = dot(fragToCam, reflectedVertex);
		
		if (specularFactor > 0.0f) {
			
			specularFactor = pow(specularFactor, material.shininess);
			specularColor = vec4(light.color * material.specularIntensity * specularFactor, 1.0f);
		}
	}
	
	return ambientColor + (1.0 - shadowFactor) * (diffColor + specularColor);
}

vec4 calcDirectionalLightInTangentSpace(Light light, float shadowFactor) {
	
	vec3 normalMap = texture(normalTexture, texCoord).rgb;
	vec3 normal = normalMap * 2.0 - 1.0;
	
	vec4 ambientColor = vec4(light.color, 1.0f) * light.ambientIntensity;
	
	float diffFactor = max(dot(normal, normalize(tangentLightDir)), 0.0f);
	
	vec4 diffColor = vec4(light.color, 1.0f) * light.diffIntensity * diffFactor;
	
	vec4 specularColor = vec4(0.0f, 0.0f, 0.0f, 0.0f);
	
	if (diffFactor > 0.0f) {
		
		vec3 fragToCam = normalize(tangentViewPos - tangentFragPos);
		vec3 reflectedVertex = normalize(reflect(-tangentLightDir, normal));
		
		float specularFactor = dot(fragToCam, reflectedVertex);
		
		if (specularFactor > 0.0f) {
			
			specularFactor = pow(specularFactor, material.shininess);
			specularColor = vec4(light.color * material.specularIntensity * specularFactor, 1.0f);
		}
	}
	
	return ambientColor + (1.0 - shadowFactor) * (diffColor + specularColor);
}

vec4 calcDirectionalLight() {
	
	float shadowFactor = calcDirShadowFactor(directionalLight);
	return calcDirectionalLightInTangentSpace(directionalLight.base, shadowFactor);
}

vec4 CalcPointLight(PointLight light) {
	
	vec3 direction = fragPos - light.position;
	float fragToLightDistance = length(direction);
	direction = normalize(direction);
	
	vec4 color = calcLightByDirection(light.base, direction, 0.0);
	float attenuation = light.exponent * fragToLightDistance * fragToLightDistance +
						light.linear * fragToLightDistance +
						light.constant;
	
	return color / attenuation;
}

vec4 CalcSpotLight(SpotLight light) {
	
	vec3 rayDirection = normalize(fragPos - light.base.position);
	float spotLightFactor = dot(rayDirection, light.direction);
	
	if (spotLightFactor > light.edge) {
		
		vec4 color = CalcPointLight(light.base);
		return color * (1.0f - (1.0f - spotLightFactor) * (1.0f / (1.0f - light.edge)));
	}
	
	return vec4(0.0f, 0.0f, 0.0f, 0.0f);
}

vec4 calcPointLights() {
	
	vec4 result = vec4(0.0f, 0.0f, 0.0f, 0.0f);
	
	for (int i = 0; i < pointLightCount; i++) {
		result += CalcPointLight(pointLights[i]);
	}
	
	return result;
}

vec4 CalcSpotLights() {
	
	vec4 result = vec4(0.0f, 0.0f, 0.0f, 0.0f);
	
	for (int i = 0; i < spotLightCount; i++) {
		result += CalcSpotLight(spotLights[i]);
	}
	
	return result;
}

vec4 LinearDepth() {
	
	float near = 0.1;
	float far = 100.0;
	
	float z = gl_FragCoord.z * 2.0 - 1.0;
	float linDepth = (2.0 * near * far) / (far + near - z * (far - near));
	
	float depth = linDepth / far;
	return vec4(vec3(depth), 1.0);
}

void main() {
	
	vec4 finalColor = calcDirectionalLight() + calcPointLights() + CalcSpotLights();
	color = texture(diffuseTexture, texCoord) * finalColor;
	// color = vec4(0.75, 0.75, 0.75, 1.0) * finalColor;
	// color = LinearDepth();
}
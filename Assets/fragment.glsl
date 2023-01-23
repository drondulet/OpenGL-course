#version 300 es
precision mediump float;

in vec4 vertColor;
in vec2 texCoord;
in vec3 normal;
in vec3 fragPos;

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

uniform sampler2D theTexture;
uniform Material material;

uniform vec3 camPosition;

vec4 calcLightByDirection(Light light, vec3 direction) {
	
	vec3 normalizedNormal = normalize(normal);
	vec4 ambientColor = vec4(light.color, 1.0f) * light.ambientIntensity;
	
	float diffFactor = max(dot(normalizedNormal, normalize(direction)), 0.0f);
	
	vec4 diffColor = vec4(light.color, 1.0f) * light.diffIntensity * diffFactor;
	
	vec4 specularColor = vec4(0.0f, 0.0f, 0.0f, 0.0f);
	
	if (diffFactor > 0.0f) {
		
		vec3 fragToCam = normalize(camPosition - fragPos);
		vec3 reflectedVertex = normalize(reflect(direction, normalizedNormal));
		
		float specularFactor = dot(fragToCam, reflectedVertex);
		
		if (specularFactor > 0.0f) {
			
			specularFactor = pow(specularFactor, material.shininess);
			specularColor = vec4(light.color * material.specularIntensity * specularFactor, 1.0f);
		}
	}
	
	return ambientColor + diffColor + specularColor;
}

vec4 calcDirectionalLight() {
	return calcLightByDirection(directionalLight.base, directionalLight.direction);
}

vec4 CalcPointLight(PointLight light) {
	
	vec3 direction = fragPos - light.position;
	float fragToLightDistance = length(direction);
	direction = normalize(direction);
	
	vec4 color = calcLightByDirection(light.base, direction);
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

void main() {
	
	vec4 finalColor = calcDirectionalLight() + calcPointLights() + CalcSpotLights();
	color = texture(theTexture, texCoord) * finalColor;
	// color = vec4(0.75, 0.75, 0.75, 1.0) * finalColor;
}
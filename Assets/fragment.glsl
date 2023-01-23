#version 300 es
precision mediump float;

in vec4 vertColor;
in vec2 texCoord;
in vec3 normal;
in vec3 fragPos;

out vec4 color;

const int MAX_POINT_LIGHTS = 3;

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

struct Material {
	float specularIntensity;
	float shininess;
};

uniform int pointLightCount;

uniform DirectionalLight directionalLight;
uniform PointLight pointLights[MAX_POINT_LIGHTS];

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

vec4 calcPointLights() {
	
	vec4 result = vec4(0.0f, 0.0f, 0.0f, 0.0f);
	
	for (int i = 0; i < pointLightCount; i++) {
		
		vec3 direction = fragPos - pointLights[i].position;
		float fragToLightDistance = length(direction);
		direction = normalize(direction);
		
		vec4 color = calcLightByDirection(pointLights[i].base, direction);
		float attenuation = pointLights[i].exponent * fragToLightDistance * fragToLightDistance +
							pointLights[i].linear * fragToLightDistance +
							pointLights[i].constant;
		
		result += color / attenuation;
	}
	
	return result;
}

void main() {
	
	
	vec4 finalColor = calcDirectionalLight() + calcPointLights();
	color = texture(theTexture, texCoord) * finalColor;
	// color = vec4(0.75, 0.75, 0.75, 1.0) * finalColor;
}
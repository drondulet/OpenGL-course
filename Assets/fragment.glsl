#version 300 es
precision mediump float;

in vec4 vertColor;
in vec2 texCoord;
in vec3 normal;
in vec3 fragPos;

out vec4 color;

struct DirectionalLight {
	vec3 color;
	float ambientIntensity;
	vec3 direction;
	float diffIntensity;
};

struct Material {
	float specularIntensity;
	float shininess;
};

uniform sampler2D theTexture;
uniform DirectionalLight directionalLight;
uniform Material material;

uniform vec3 camPosition;

void main()
{
	vec3 normalizedNormal = normalize(normal);
	vec4 ambientColor = vec4(directionalLight.color, 1.0f) * directionalLight.ambientIntensity;
	
	float diffFactor = max(dot(normalizedNormal, normalize(directionalLight.direction)), 0.0);
	
	vec4 diffColor = vec4(directionalLight.color, 1.0) * directionalLight.diffIntensity * diffFactor;
	
	vec4 specularColor = vec4(0, 0, 0, 0);
	
	if (diffFactor > 0.0f) {
		
		vec3 fragToCam = normalize(camPosition - fragPos);
		vec3 reflectedVertex = normalize(reflect(directionalLight.direction, normalizedNormal));
		
		float specularFactor = dot(fragToCam, reflectedVertex);
		
		if (specularFactor > 0.0f) {
			
			specularFactor = pow(specularFactor, material.shininess);
			specularColor = vec4(directionalLight.color * material.specularIntensity * specularFactor, 1.0f);
		}
	}
	
	color = texture(theTexture, texCoord) * (ambientColor + diffColor + specularColor);
}
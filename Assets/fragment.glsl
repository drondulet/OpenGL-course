#version 300 es
precision mediump float;

in vec4 vertColor;
in vec2 texCoord;
in vec3 normal;

out vec4 color;

struct DirectionalLight {
	vec3 color;
	float ambientIntensity;
	vec3 direction;
	float diffIntensity;
};

uniform sampler2D theTexture;
uniform DirectionalLight directionalLight;

void main()
{
	vec4 ambientColor = vec4(directionalLight.color, 1.0f) * directionalLight.ambientIntensity;
	
	float diffFactor = max(dot(normalize(normal), normalize(directionalLight.direction)), 0.0);
	
	vec4 diffColor = vec4(directionalLight.color, 1.0) * directionalLight.diffIntensity * diffFactor;
	
	color = texture(theTexture, texCoord) * (ambientColor + diffColor);
}
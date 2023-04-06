#version 300 es
precision highp float;

in vec2 texCoord;

uniform sampler2D diffuseTexture;
uniform sampler2D normalTexture;
uniform sampler2D dirShadowMapTexture;

out vec4 color;

vec4 LinearDepth(float currDepth) {
	
	float near = 0.1;
	float far = 100.0;
	
	float z = currDepth * 2.0 - 1.0;
	float linDepth = (2.0 * near * far) / (far + near - z * (far - near));
	
	float depth = linDepth / far;
	return vec4(vec3(depth), 1.0);
}

void main() {
	vec4 diffuseTexel = texture(diffuseTexture, texCoord);
	vec4 normalTexel = texture(normalTexture, texCoord);
	vec4 depthTexel = vec4(vec3(texture(dirShadowMapTexture, texCoord).r), 1);
	color = depthTexel;
	// color = LinearDepth(texture(dirShadowMapTexture, texCoord).r);
}
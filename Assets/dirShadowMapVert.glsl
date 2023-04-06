#version 300 es
precision highp float;

layout (location = 0) in vec3 attPos;
// layout (location = 1) in vec2 attTexCoords;

uniform mat4 model;
uniform mat4 dirLightSpaceTransform; // projection * view

// out vec2 texCoord;

void main() {
	
	// texCoord = attTexCoords;
	gl_Position = dirLightSpaceTransform * model * vec4(attPos, 1);
}
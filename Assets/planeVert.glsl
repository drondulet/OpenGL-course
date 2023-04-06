#version 300 es
precision highp float;

layout (location = 0) in vec3 attPos;
layout (location = 1) in vec2 attTexCoords;

out vec2 texCoord;

void main() {
	
	texCoord = attTexCoords;
	gl_Position = vec4(attPos, 1);
}
#version 300 es
precision mediump float;

layout (location = 0) in vec3 pos;
layout (location = 1) in vec2 texCoords;
layout (location = 2) in vec3 norm;

out vec4 vertColor;
out vec2 texCoord;
out vec3 normal;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
	gl_Position = projection * view * model * vec4(pos, 1.0f);
	vertColor = vec4(clamp(pos, 0.0f, 1.0f), 1.0f);
	texCoord = texCoords;
	normal = mat3(transpose(inverse(model))) * norm;
}
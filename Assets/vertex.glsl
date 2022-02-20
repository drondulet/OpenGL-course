#version 300 es
precision mediump float;

layout (location = 0) in vec3 pos;

out vec4 vertColor;

uniform mat4 model;
uniform mat4 projection;

void main()
{
	gl_Position = projection * model * vec4(pos, 1.0f);
	vertColor = vec4(clamp(pos, 0.0f, 1.0f), 1.0f);
}
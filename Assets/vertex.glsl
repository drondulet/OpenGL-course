#version 300 es
precision mediump float;

layout (location = 0) in vec3 attPos;
layout (location = 1) in vec2 attTexCoords;
layout (location = 2) in vec3 attNormal;
layout (location = 3) in vec4 attTangent;

out vec4 vertColor;
out vec2 texCoord;
out vec3 normal;
out vec3 fragPos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
	vec4 pos4 = vec4(attPos, 1.0f);
	gl_Position = projection * view * model * pos4;
	texCoord = attTexCoords;
	normal = mat3(transpose(inverse(model))) * attNormal;
	fragPos = (model * pos4).xyz;
}
#version 300 es
precision highp float;

layout (location = 0) in vec3 attPos;
layout (location = 1) in vec2 attTexCoords;
layout (location = 2) in vec3 attNormal;
layout (location = 3) in vec4 attTangent;

out vec4 vertColor;
out vec2 texCoord;
out vec3 normal;
out vec3 fragPos;
out vec3 tangentLightDir;
out vec3 tangentViewPos;
out vec3 tangentFragPos;
out vec4 dirLightSpacePos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform vec3 lightDir;
uniform vec3 viewPos;
uniform mat4 dirLightSpaceTransform; // projection * view

void main()
{
	vec4 pos4 = vec4(attPos, 1.0f);
	gl_Position = projection * view * model * pos4;
	texCoord = attTexCoords;
	normal = mat3(transpose(inverse(model))) * attNormal; // scale independent normal
	fragPos = (model * pos4).xyz;
	
	vec3 tangent = attTangent.xyz;
	vec3 T = normalize(vec3(model * vec4(tangent, 0.0)));
	vec3 N = normalize(normal);
	T = normalize(T - dot(T, N) * N); // Gram Schmidt process
	vec3 B = cross(N, T);
	
	mat3 TBN = transpose(mat3(T, B, N));
	tangentLightDir = TBN * -lightDir;
	// tangentLightDir.x = dot(-lightDir, T);
	// tangentLightDir.y = dot(-lightDir, B);
	// tangentLightDir.z = dot(-lightDir, N);
	tangentViewPos = TBN * viewPos;
	tangentFragPos = TBN * fragPos;
	
	dirLightSpacePos = dirLightSpaceTransform * model * pos4;
}
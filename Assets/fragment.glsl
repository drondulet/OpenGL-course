#version 300 es
precision mediump float;

in vec4 vertColor;
in vec2 texCoord;

out vec4 color;

uniform sampler2D theTexture;

void main()
{
	color = texture(theTexture, texCoord);
}
#version 120

uniform float viewHeight;
uniform float viewWidth;

varying vec2 texcoord;
varying vec2 inverseViewSize;

void main() {
	inverseViewSize = vec2(1.0/viewWidth, 1.0/viewHeight);
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
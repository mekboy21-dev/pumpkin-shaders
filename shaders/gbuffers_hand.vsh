#version 120

attribute vec4 mc_Entity;
uniform vec3 shadowLightPosition;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying float lightDot;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	lightDot = clamp(dot(normalize(shadowLightPosition), normalize(gl_NormalMatrix * gl_Normal)), 0., 1.);
	if (mc_Entity.x == 10000.0) lightDot = 1.0;
}


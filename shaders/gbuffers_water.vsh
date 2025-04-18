#version 120

attribute vec4 mc_Entity;
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying float reflectMixAmount;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	
	reflectMixAmount = 0.2;

	if (mc_Entity.x == 10001.0) { 
		reflectMixAmount = 0.;
	}


}
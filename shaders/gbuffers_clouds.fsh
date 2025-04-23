#version 120

uniform sampler2D texture;
uniform float rainStrength;

varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	vec4 color = vec4(0.8);
	color.rgb /= rainStrength * 10;


/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}
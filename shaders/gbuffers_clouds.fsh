#version 120

uniform sampler2D texture;
uniform float rainStrength;
uniform float sunAngle;

varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, texcoord);
	color.rgb /= rainStrength * 10;
	color.a *= 0.25;


/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}

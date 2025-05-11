#version 120

uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;

varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.

void main() {
	vec3 color;
	color = fogColor;
	if (starData.a > 0.5) {
		color = starData.rgb;
	}

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}
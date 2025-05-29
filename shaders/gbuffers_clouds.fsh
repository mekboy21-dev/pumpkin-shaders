#version 120

uniform sampler2D texture;
uniform float rainStrength;
uniform float sunAngle;

varying vec2 texcoord;
varying vec4 glcolor;

#include "/settings.glsl"

#ifdef SOLID_COLOR_CLOUDS
	void main() {
		vec4 color = texture2D(texture, texcoord);
		color.rgb /= rainStrength * 10;
		color.a *= 0.25;


	/* DRAWBUFFERS:0 */
		gl_FragData[0] = color; //gcolor
	}
#else
	void main() {
		vec4 color = texture2D(texture, texcoord) * glcolor;

	/* DRAWBUFFERS:0 */
		gl_FragData[0] = color; //gcolor
	}
#endif

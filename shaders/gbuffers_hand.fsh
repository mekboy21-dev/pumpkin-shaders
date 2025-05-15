#version 120
uniform sampler2D lightmap;
uniform sampler2D texture;

uniform vec4 entityColor;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying float lightDot;

#include "/settings.glsl"

void main() {
	// define variables ready for lighting calculations
	vec4 color = texture2D(texture, texcoord) * glcolor;
	vec3 torch_color = vec3(BLOCK_LIGHT_COLOR_R, BLOCK_LIGHT_COLOR_G, BLOCK_LIGHT_COLOR_B) * BLOCK_LIGHT_BRIGHTNESS;
	vec3 sky_light_color = vec3(SKY_LIGHT_COLOR_R, SKY_LIGHT_COLOR_G, SKY_LIGHT_COLOR_B);


	// calculate lighting
	color.rgb *= clamp((lightDot * sky_light_color) + (lmcoord.x * torch_color) + (lmcoord.y * sky_light_color) + AMBIENT, 0., 1.);
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}


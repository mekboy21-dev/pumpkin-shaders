#version 120
uniform sampler2D lightmap;
uniform sampler2D texture;

uniform vec4 entityColor;
uniform vec3 fogColor;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying float lightDot;

#include "/settings.glsl"

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	// define variables ready for lighting calculations
	vec3 torch_color = vec3(BLOCK_LIGHT_COLOR_R, BLOCK_LIGHT_COLOR_G, BLOCK_LIGHT_COLOR_B) * BLOCK_LIGHT_BRIGHTNESS;
	#if CUSTOM_SKY_COLOR == 1
		vec3 sky_light_color = vec3(SKY_LIGHT_COLOR_R, SKY_LIGHT_COLOR_G, SKY_LIGHT_COLOR_B) * SKY_LIGHT_BRIGHTNESS;
	#else
		vec3 sky_light_color = fogColor * 0.3;
	#endif
	vec3 sun_light_color = vec3(SUN_LIGHT_COLOR_R, SUN_LIGHT_COLOR_G, SUN_LIGHT_COLOR_B) * SUN_LIGHT_BRIGHTNESS;


	// calculate lighting
	color.rgb *= (lightDot * sun_light_color) + (lmcoord.x * torch_color) + (lmcoord.y * sky_light_color) + AMBIENT;
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}


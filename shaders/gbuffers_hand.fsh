#version 120
uniform sampler2D lightmap;
uniform sampler2D texture;

uniform sampler2D shadowtex1;
uniform sampler2D noisetex;

uniform float viewWidth;
uniform float viewHeight;

uniform vec4 entityColor;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying float lightDot;
varying vec4 shadowPos;

#include "/settings.glsl"

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	vec3 torch_color = vec3(BLOCK_LIGHT_COLOR_R, BLOCK_LIGHT_COLOR_G, BLOCK_LIGHT_COLOR_B) * BLOCK_LIGHT_BRIGHTNESS;
	vec3 sky_light_color = vec3(SKY_LIGHT_COLOR_R, SKY_LIGHT_COLOR_G, SKY_LIGHT_COLOR_B);

	float sky = texture2D(lightmap, lmcoord).y * lmcoord.y;
	
	color.rgb *= clamp(torch_color * lmcoord.x + (lightDot * sky * sky_light_color) + sky * 0.5+ (AMBIENT * sky_light_color), 0. ,1.);
	color *= texture2D(lightmap, lmcoord);
    color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}


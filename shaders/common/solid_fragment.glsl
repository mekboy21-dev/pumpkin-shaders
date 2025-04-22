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

#if SOFTEN_SHADOWS == 1 
float offset_lookup(vec2 offset, vec2 texelSize){
	float result = 0.;
	float pcfDepth = texture2D(shadowtex1, shadowPos.xy + offset * texelSize).r; 
   	result += shadowPos.z > pcfDepth  ? 1.0 : 0.0;   

	return result;
}
#endif

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	vec3 torch_color = vec3(BLOCK_LIGHT_COLOR_R, BLOCK_LIGHT_COLOR_G, BLOCK_LIGHT_COLOR_B) * BLOCK_LIGHT_BRIGHTNESS;
	vec3 sky_light_color = vec3(SKY_LIGHT_COLOR_R, SKY_LIGHT_COLOR_G, SKY_LIGHT_COLOR_B);
	float ambient = 0.025; // no idea if this is even the right term but it makes unlit places brighter
	float sky = texture2D(lightmap, lmcoord).y * lmcoord.y;
	
	#if SHADOWS_ENABLED == 1
		float shadow = 0.0;
		#if SOFTEN_SHADOWS == 1 
				ivec2 screenCoord = ivec2(texcoord * vec2(viewWidth, viewHeight)); // exact pixel coordinate onscreen
				vec2 texelSize = 1.0 / textureSize(shadowtex1, 0);
				ivec2 noiseCoord = screenCoord % 64;
				vec2 offset = vec2(texelFetch(noisetex, noiseCoord, 0).r);

				shadow = ( // this may look horrific but it helps when it comes to performance on some lower end hardware
					offset_lookup(offset + vec2(-3.0, -3.0), texelSize) +
					offset_lookup(offset + vec2(-2.0, -3.0), texelSize) +
					offset_lookup(offset + vec2(-1.0, -3.0), texelSize) +
					offset_lookup(offset + vec2(0.0, -3.0), texelSize) +
					offset_lookup(offset + vec2(1.0, -3.0), texelSize) +
					offset_lookup(offset + vec2(2.0, -3.0), texelSize) +
					offset_lookup(offset + vec2(3.0, -3.0), texelSize) +

					offset_lookup(offset + vec2(-3.0, -2.0), texelSize) +
					offset_lookup(offset + vec2(-2.0, -2.0), texelSize) +
					offset_lookup(offset + vec2(-1.0, -2.0), texelSize) +
					offset_lookup(offset + vec2(0.0, -2.0), texelSize) +
					offset_lookup(offset + vec2(1.0, -2.0), texelSize) +
					offset_lookup(offset + vec2(2.0, -2.0), texelSize) +
					offset_lookup(offset + vec2(3.0, -2.0), texelSize) +

					offset_lookup(offset + vec2(-3.0, -1.0), texelSize) +
					offset_lookup(offset + vec2(-2.0, -1.0), texelSize) +
					offset_lookup(offset + vec2(-1.0, -1.0), texelSize) +
					offset_lookup(offset + vec2(0.0, -1.0), texelSize) +
					offset_lookup(offset + vec2(1.0, -1.0), texelSize) +
					offset_lookup(offset + vec2(2.0, -1.0), texelSize) +
					offset_lookup(offset + vec2(3.0, -1.0), texelSize) +

					offset_lookup(offset + vec2(-3.0, 0.0), texelSize) +
					offset_lookup(offset + vec2(-2.0, 0.0), texelSize) +
					offset_lookup(offset + vec2(-1.0, 0.0), texelSize) +
					offset_lookup(offset + vec2(0.0, 0.0), texelSize) +
					offset_lookup(offset + vec2(1.0, 0.0), texelSize) +
					offset_lookup(offset + vec2(2.0, 0.0), texelSize) +
					offset_lookup(offset + vec2(3.0, 0.0), texelSize) +

					offset_lookup(offset + vec2(-3.0, 1.0), texelSize) +
					offset_lookup(offset + vec2(-2.0, 1.0), texelSize) +
					offset_lookup(offset + vec2(-1.0, 1.0), texelSize) +
					offset_lookup(offset + vec2(0.0, 1.0), texelSize) +
					offset_lookup(offset + vec2(1.0, 1.0), texelSize) +
					offset_lookup(offset + vec2(2.0, 1.0), texelSize) +
					offset_lookup(offset + vec2(3.0, 1.0), texelSize) +

					offset_lookup(offset + vec2(-3.0, 2.0), texelSize) +
					offset_lookup(offset + vec2(-2.0, 2.0), texelSize) +
					offset_lookup(offset + vec2(-1.0, 2.0), texelSize) +
					offset_lookup(offset + vec2(0.0, 2.0), texelSize) +
					offset_lookup(offset + vec2(1.0, 2.0), texelSize) +
					offset_lookup(offset + vec2(2.0, 2.0), texelSize) +
					offset_lookup(offset + vec2(3.0, 2.0), texelSize) +

					offset_lookup(offset + vec2(-3.0, 3.0), texelSize) +
					offset_lookup(offset + vec2(-2.0, 3.0), texelSize) +
					offset_lookup(offset + vec2(-1.0, 3.0), texelSize) +
					offset_lookup(offset + vec2(0.0, 3.0), texelSize) +
					offset_lookup(offset + vec2(1.0, 3.0), texelSize) +
					offset_lookup(offset + vec2(2.0, 3.0), texelSize) +
					offset_lookup(offset + vec2(3.0, 3.0), texelSize)
				) * 0.02040816326;

		#else
			if (texture2D(shadowtex1, shadowPos.xy).r < shadowPos.z) {
				shadow = 1.0;
			}
		#endif

		if (lightDot > 0.01) { // the 0.01 here helps prevent against flickering on the north face of blocks
			color.rgb *= clamp(torch_color * lmcoord.x + (lightDot * sky * sky_light_color) + sky * 0.5+ ambient, 0. ,1.);
			color.rgb *= SHADOW_BRIGHTNESS * shadow + (1.0 - shadow);
		}

		if (shadowPos == vec4(0.)) {
			color.rgb *= torch_color * lmcoord.x + (1. - SHADOW_BRIGHTNESS) * sky;
		}

	#else
		color.rgb *= clamp(torch_color * lmcoord.x + (lightDot * sky * sky_light_color) + sky * 0.5+ ambient, 0. ,1.);
	#endif
	color *= texture2D(lightmap, lmcoord);
    color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}
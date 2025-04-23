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

#if SOFTEN_SHADOWS != 0 
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
	
	#ifdef SHADOWS_ENABLED
		float shadow = 0.0;
		#if SOFTEN_SHADOWS == 2 
				// use 16 samples - gives better results
				vec2 texelSize = 1.0 / textureSize(shadowtex1, 0);

				for (float y = -1.5; y <= 1.5; y++) {
					for (float x = -1.5; x<= 1.5; x++) {
						shadow += offset_lookup(vec2(x,y), texelSize);
					}
				}
				shadow /= 16;
		#elif SOFTEN_SHADOWS == 1
				// use 4 samples and dither - might be more performant on lower end hardware
				vec2 texelSize = 1.0 / textureSize(shadowtex1, 0);

				ivec2 screenCoord = ivec2(texcoord * vec2(viewWidth, viewHeight)); // exact pixel coordinate onscreen
				vec2 offset = vec2(greaterThan(fract(screenCoord.xy * 0.5), vec2(0.25)));

				offset.y += offset.x;
				if (offset.y > 1.1) {
  					offset.y = 0;
				}
				shadow = ( 
						offset_lookup(offset + vec2(-1.5, -0.5), texelSize) +
						offset_lookup(offset + vec2(0.5, 0.5), texelSize) +
						offset_lookup(offset + vec2(-1.5, -1.5), texelSize) +
						offset_lookup(offset + vec2(0.5, -1.5), texelSize) 
				) * 0.25;
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


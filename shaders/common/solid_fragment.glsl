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
float offset_lookup(vec2 offset){
	float result = 0.;
	float pcfDepth = texture2D(shadowtex1, shadowPos.xy + offset * (1.0 / vec2(shadowMapResolution))).r;
   	result += shadowPos.z > pcfDepth  ? 1.0 : 0.0;   

	return result;
}
#endif



#if SOFTEN_SHADOWS == 3
	float getNoise(vec2 coord) {
		//vec2 noiseUV = mod(texcoord * vec2(viewWidth, viewHeight), 256.0) / 256.0;
		//return texture2D(noisetex, noiseUV).r;

		return fract(sin(dot(floor(coord * 256.0), vec2(127.1, 311.7))) * 43758.5453);
	}
#endif

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	vec3 torch_color = vec3(BLOCK_LIGHT_COLOR_R, BLOCK_LIGHT_COLOR_G, BLOCK_LIGHT_COLOR_B) * BLOCK_LIGHT_BRIGHTNESS;
	vec3 sky_light_color = vec3(SKY_LIGHT_COLOR_R, SKY_LIGHT_COLOR_G, SKY_LIGHT_COLOR_B);

	float sky = texture2D(lightmap, lmcoord).y * lmcoord.y;
	
	#ifdef SHADOWS_ENABLED
		float shadow = 0.0;
		#if SOFTEN_SHADOWS == 3 
				// 16 samples but further blurred using noise
				float theta = getNoise(texcoord); // random angle using noise value
  				float cosTheta = cos(theta);
  				float sinTheta = sin(theta);

 				mat2 offset = mat2(cosTheta, -sinTheta, sinTheta, cosTheta); // matrix to rotate the offset around the original position by the angle
									
				for(float x = -1.5; x <= 1.5; ++x) {
					for(float y = -1.5; y <= 1.5; ++y) {
						shadow += offset_lookup(offset * vec2(x,y));
					}
				}

				shadow /= 16.0;
		#elif SOFTEN_SHADOWS == 2
				// nine samples - how it was implemented in V.0.5
									
				for(int x = -1; x <= 1; ++x) {
					for(int y = -1; y <= 1; ++y) {
						shadow += offset_lookup(vec2(x,y));
					}
				}

				shadow /= 9.0;
		#elif SOFTEN_SHADOWS == 1
				// use 4 samples and dither - might be more performant on lower end hardware
				ivec2 screenCoord = ivec2(texcoord * vec2(viewWidth, viewHeight)); // exact pixel coordinate onscreen
				vec2 offset = vec2(greaterThan(fract(screenCoord.xy * 0.5), vec2(0.25)));

				offset.y += offset.x;
				if (offset.y > 1.1) {
  					offset.y = 0;
				}
				shadow = ( 
						offset_lookup(offset + vec2(-1.5, -0.5)) +
						offset_lookup(offset + vec2(0.5, 0.5)) +
						offset_lookup(offset + vec2(-1.5, -1.5)) +
						offset_lookup(offset + vec2(0.5, -1.5))
				) * 0.25;
		#else
			if (texture2D(shadowtex1, shadowPos.xy).r < shadowPos.z) {
				shadow = 1.0;
			}
		#endif

		if (lightDot > 0.02) { // the 0.02 here helps prevent against flickering on the north face of blocks
			color.rgb *= clamp(torch_color * lmcoord.x + (lightDot * sky * sky_light_color) + sky * 0.5+ (AMBIENT * sky_light_color), 0. ,1.);
			color.rgb *= SHADOW_BRIGHTNESS * shadow + (1.0 - shadow);
		}

		if (shadowPos == vec4(0.)) {
			color.rgb *= torch_color * lmcoord.x + (1. - SHADOW_BRIGHTNESS) * sky + (AMBIENT * sky_light_color);
		}

	#else
		color.rgb *= clamp(torch_color * lmcoord.x + (lightDot * sky * sky_light_color) + sky * 0.5+ (AMBIENT * sky_light_color), 0. ,1.);
	#endif
	color *= texture2D(lightmap, lmcoord);
    color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}


uniform sampler2D lightmap;
uniform sampler2D texture;

uniform sampler2D shadowtex1;
uniform sampler2D noisetex;

uniform float viewWidth;
uniform float viewHeight;

uniform vec4 entityColor;
uniform vec3 fogColor;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying float lightDot;
varying vec4 shadowPos;
varying float brightness;

#include "/settings.glsl"

#if SOFTEN_SHADOWS != 0 
float offset_lookup(vec2 offset, vec2 texelSize){
	float result = 0.;
	float pcfDepth = texture2D(shadowtex1, shadowPos.xy + offset * texelSize).r;
   	result += shadowPos.z > pcfDepth  ? 1.0 : 0.0;   

	return result;
}
#endif

#if SOFTEN_SHADOWS == 3
	float getNoise(vec2 coord) {
		vec2 noiseUV = texcoord * vec2(viewWidth, viewHeight / noiseTextureResolution);
		return texture2D(noisetex, noiseUV).r;
	}
#endif

void main() {
	// define variables ready for lighting calculations
	vec4 color = texture2D(texture, texcoord) * glcolor;
	vec3 torch_color = vec3(BLOCK_LIGHT_COLOR_R, BLOCK_LIGHT_COLOR_G, BLOCK_LIGHT_COLOR_B) * BLOCK_LIGHT_BRIGHTNESS;
	#if CUSTOM_SKY_COLOR == 1
		vec3 sky_light_color = vec3(SKY_LIGHT_COLOR_R, SKY_LIGHT_COLOR_G, SKY_LIGHT_COLOR_B) * SKY_LIGHT_BRIGHTNESS;
	#else
		vec3 sky_light_color = fogColor * 0.3;
	#endif
	vec3 sun_light_color = vec3(SUN_LIGHT_COLOR_R, SUN_LIGHT_COLOR_G, SUN_LIGHT_COLOR_B) * SUN_LIGHT_BRIGHTNESS;
	
	#ifdef SHADOWS_ENABLED
		// calculate shadows
		float shadow = 0.0;

		// workout where shadow is & soften if enabled
		#if SOFTEN_SHADOWS == 3 
				// 16 samples but further blurred using noise
				float theta = getNoise(texcoord); // random angle using noise value
  				float cosTheta = cos(theta);
  				float sinTheta = sin(theta);

 				mat2 offset = mat2(cosTheta, -sinTheta, sinTheta, cosTheta); // matrix to rotate the offset around the original position by the angle

				vec2 texelSize = 1.0 / vec2(shadowMapResolution);

				for(float x = -1.5; x <= 1.5; ++x) {
					for(float y = -1.5; y <= 1.5; ++y) {
						shadow += offset_lookup(offset * vec2(x,y), texelSize);
					}
				}

				shadow /= 16.0;
		#elif SOFTEN_SHADOWS == 2
				// nine samples - how it was implemented in V.0.5

				vec2 texelSize = 1.0 / vec2(shadowMapResolution);

				for(int x = -1; x <= 1; ++x) {
					for(int y = -1; y <= 1; ++y) {
						shadow += offset_lookup(vec2(x,y), texelSize);
					}
				}

				shadow /= 9.0;
		#elif SOFTEN_SHADOWS == 1
				// use 4 samples and dither - might be more performant on lower end hardware
				ivec2 screenCoord = ivec2(texcoord * vec2(viewWidth, viewHeight)); // exact pixel coordinate onscreen
				vec2 offset = vec2(greaterThan(fract(screenCoord.xy * 0.5), vec2(0.25)));

				vec2 texelSize = 1.0 / vec2(shadowMapResolution);

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

		if (brightness > 1.0) {
			// glowing
			shadow = 0.0;
			color.rgb * brightness;
		}

		// final lighting calculations
		if (lightDot > 0.02) { // the 0.02 here helps prevent against flickering on the north face of blocks
			// calculate lighting
			color.rgb *= (lightDot * sun_light_color) + (lmcoord.x * torch_color) + (lmcoord.y * sky_light_color) + AMBIENT;
			// darken based on shadow variable
			color.rgb *= (SHADOW_BRIGHTNESS * shadow + (1.0 - shadow)) + (sky_light_color * 0.5 * shadow);
		}

		if (shadowPos == vec4(0.)) {
			// pixel is 100% in shadow
			// calculate lighting
			color.rgb *= (lightDot * sun_light_color) + (lmcoord.x * torch_color) + (lmcoord.y * sky_light_color) + AMBIENT;
			// darken
			color.rgb *= SHADOW_BRIGHTNESS + (sky_light_color * 0.5);
		}

	#else
		// calculate lighting
		color.rgb *= (lightDot * sun_light_color) + (lmcoord.x * torch_color) + (lmcoord.y * sky_light_color) + AMBIENT;
	#endif

	color *= texture2D(lightmap, lmcoord); // lightmap
    color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a); // entity color
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}


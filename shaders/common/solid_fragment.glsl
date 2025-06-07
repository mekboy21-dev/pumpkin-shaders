uniform sampler2D lightmap;
uniform sampler2D texture;

uniform sampler2DShadow shadowtex1;
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
	
	color.rgb * brightness;
	#ifdef SHADOWS_ENABLED
		// final lighting calculations
		if (lightDot > 0.02) { // the 0.02 here helps prevent against flickering on the north face of blocks
			// calculate lighting
			float shadow = 0.0;
			// check if glowing
			if (brightness > 1.0) {
			} else {
				// calculate shadows

				#ifdef PCF		
				    float xOffset = 1.0/shadowMapResolution;
					float yOffset = 1.0/shadowMapResolution;

					float Factor = 0.0;

					for (int y = -1 ; y <= 1 ; y++) {
						for (int x = -1 ; x <= 1 ; x++) {
							vec2 Offsets = vec2(x * xOffset, y * yOffset);
							vec3 UVC = vec3(shadowPos.xy + Offsets, shadowPos.z + 0.00001);
							#ifdef IS_IRIS
								Factor += texture(shadowtex1, UVC);
							#else
								Factor += shadow2D(shadowtex1, UVC).r;
							#endif
						}
					}

					Factor = (0.5 + (Factor / 18.0));

					shadow = Factor;
				#else 
					#ifdef IS_IRIS
						shadow = textureProj(shadowtex1, shadowPos);
					#else
						shadow = shadow2DProj(shadowtex1, shadowPos).r;
					#endif
				#endif
				shadow = clamp(1.0 - shadow, 0.0, 1.0 - SHADOW_BRIGHTNESS);
			}
			color.rgb *= (lightDot * sun_light_color * (1.0 - shadow)) + (lmcoord.x * torch_color) + (lmcoord.y * sky_light_color) + AMBIENT;
		}

		if (shadowPos == vec4(0.)) {
			// pixel is 100% in shadow
			// calculate lighting
			color.rgb *= (lightDot * sun_light_color * (1.0 - (1.0 -SHADOW_BRIGHTNESS))) + (lmcoord.x * torch_color) + (lmcoord.y * sky_light_color) + AMBIENT;
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


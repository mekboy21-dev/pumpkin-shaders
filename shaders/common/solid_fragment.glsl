uniform sampler2D lightmap;
uniform sampler2D texture;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;

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
	float ambient = 0.025; // no idea if this is even the right term but it makes unlit places brighter
	float sky = texture2D(lightmap, lmcoord).y * lmcoord.y;
	
	#if SHADOWS_ENABLED == 1
		float shadow = 0.0;
		#if SOFTEN_SHADOWS == 1 
		
    		vec2 texelSize = 1.0 / textureSize(shadowtex1, 0);
    		for(int x = -1; x <= 1; ++x)
    		{
        		for(int y = -1; y <= 1; ++y)
        		{
           			float pcfDepth = texture2D(shadowtex1, shadowPos.xy + vec2(x, y) * texelSize).r; 
            		shadow += shadowPos.z > pcfDepth  ? 1.0 : 0.0;        
        		}    
    		}

			shadow /= 9.0;
		#else
			if (texture2D(shadowtex1, shadowPos.xy).r < shadowPos.z) {
				shadow = 1.0;
			}
		#endif

		if (lightDot > 0.01) { // the 0.01 here helps prevent against flickering on the north face of blocks
			color.rgb *= (ambient * 20) * sky + (1.0 - shadow);
			color.rgb *= clamp(torch_color * lmcoord.x + (lightDot * sky * sky_light_color) + sky * 0.5, 0. ,1.);
		}

		if (shadowPos == vec4(0.)) {
			color.rgb *= torch_color * lmcoord.x + (ambient * 10) * sky;
		}

	#else
		color.rgb *= clamp(torch_color * lmcoord.x + (lightDot * sky * sky_light_color) + sky * 0.5+ ambient, 0. ,1.);
	#endif
	color *= texture2D(lightmap, lmcoord);
    color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}
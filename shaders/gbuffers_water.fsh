#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;

uniform vec3 shadowLightPosition;
uniform vec3 skyColor;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying float reflectMixAmount;

void main() {
	vec4 color = texture2D(texture, texcoord);
	color.rgb *= glcolor.rgb * 0.5;
	vec2 lm = lmcoord;

	color *= texture2D(lightmap, lm);

	color.rgb=mix(color.rgb, skyColor, reflectMixAmount);
	
/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}
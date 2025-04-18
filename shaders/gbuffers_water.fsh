#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;

uniform float sunAngle;
uniform vec3 shadowLightPosition;
uniform vec3 skyColor;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 normals_face;


void main() {
	vec4 color = texture2D(texture, texcoord);
	color.rgb *= glcolor.rgb * 0.3;
	vec2 lm = lmcoord;

	color *= texture2D(lightmap, lm);

	color.rgb=mix(color.rgb, skyColor, 0.3);


	//color.a = 0.35;

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}
#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	// calculate color
	vec4 color = texture2D(texture, texcoord) * ((glcolor / 1.5) * texture2D(lightmap, lmcoord));
	color *= texture2D(lightmap, lmcoord);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}
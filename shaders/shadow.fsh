#version 120

uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

void main() {
    #if SHADOWS_ENABLED == 1
	    vec4 color = texture2D(texture, texcoord) * glcolor;

    /* DRAWBUFFERS:0 */
	    gl_FragData[0] = color;
    #endif
}
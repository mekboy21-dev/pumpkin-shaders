#version 120

#define FOG_DENSITY 4.0

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform vec3 fogColor;

uniform float far;
uniform mat4 gbufferProjectionInverse;

varying vec2 texcoord;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
  vec4 homPos = projectionMatrix * vec4(position, 1.0);
  return homPos.xyz / homPos.w;
}

void main() {
	vec3 color = texture2D(colortex0, texcoord).rgb;

    float depth = texture(depthtex0, texcoord).r;
    if(depth == 1.0){
        return;
    }

    vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
    vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);

    
    if (color.rgb != fogColor) {
        color.rgb = mix(color.rgb, fogColor, clamp(exp(-FOG_DENSITY * (1.0 - length(viewPos) / far)), 0.0, 1.0)); // i honestly have no fucking idea why putting this all on one line is the only way i can get fog to work
    }
    
    /* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor 
}
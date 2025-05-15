attribute vec4 mc_Entity;

uniform mat4 gbufferModelViewInverse;
uniform vec3 shadowLightPosition;
uniform mat4 shadowProjection;
uniform mat4 shadowModelView;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying float lightDot;
varying vec4 shadowPos;
varying float bias;

#include "/settings.glsl"
#include "/shadow_distort.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	// calculate lightDot
	lightDot = clamp(dot(normalize(shadowLightPosition), normalize(gl_NormalMatrix * gl_Normal)), 0., 1.);
	if (mc_Entity.x == 10000.0) lightDot = 1.0;

	// calculate shadows
	#ifdef SHADOWS_ENABLED
		vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
		if (lightDot > 0.02) { // the 0.02 here helps prevent against flickering on the north face of blocks
			// in sunlight 
			vec4 playerPos = gbufferModelViewInverse * viewPos;
			shadowPos = shadowProjection * (shadowModelView * playerPos);
			bias = computeBias(shadowPos.xyz);
			shadowPos.xyz = distort(shadowPos.xyz); 
			shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5;

			// maybe add normal bias?
			shadowPos.z -= bias / abs(lightDot);
		} else {
			shadowPos = vec4(0.0);
		}

		
		gl_Position = gl_ProjectionMatrix * viewPos;

	#else 
		gl_Position = ftransform();
	#endif
}


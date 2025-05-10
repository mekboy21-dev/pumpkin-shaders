#version 120

#define DRAW_SHADOW_MAP colortex0 //Configures which buffer to draw to the screen [gcolor shadowcolor0 shadowtex0 shadowtex1]
#define FXAA_EDGE_THRESHOLD_MIN 1./16.
#define FXAA_EDGE_THRESHOLD 1./8.
#define FXAA_SUBPIX_TRIM 1./3.
#define FXAA_SUBPIX_TRIM_SCALE (1./(1. - FXAA_SUBPIX_TRIM))
#define FXAA_SUBPIX_CAP 3./4.
#define FXAA_SEARCH_STEPS 16
#define FXAA_SEARCH_THRESHOLD 1./4.

uniform float frameTimeCounter;
uniform sampler2D colortex0;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;

varying vec2 inverseViewSize;
varying vec2 texcoord;


#include "/settings.glsl"


#ifdef FXAA
	float getLuma(vec3 rgb) {
    	return rgb.g * (0.587/0.299) + rgb.r; 
	}
#endif

void main() {
	
	vec3 color = texture2D(colortex0, texcoord).rgb;

#ifdef FXAA
	// Local Contrast Check
	vec3 rgbN = texture2D(colortex0, texcoord+vec2(0., -1.)*inverseViewSize).rgb;
	vec3 rgbW = texture2D(colortex0, texcoord+vec2(-1., -0.)*inverseViewSize).rgb;
	vec3 rgbM = texture2D(colortex0, texcoord+vec2(0., 0.)*inverseViewSize).rgb;
	vec3 rgbE = texture2D(colortex0, texcoord+vec2(1., 0.)*inverseViewSize).rgb;
	vec3 rgbS = texture2D(colortex0, texcoord+vec2(0., 1.)*inverseViewSize).rgb;

	float lumaN = getLuma(rgbN);
	float lumaW = getLuma(rgbW);
	float lumaM = getLuma(rgbM);
	float lumaE = getLuma(rgbE);
	float lumaS = getLuma(rgbS);

	// minimum and maximum luma & luma range
	float minLuma = min(lumaM, min(min(lumaN, lumaW), min(lumaS, lumaE)));
	float maxLuma = max(lumaM, max(max(lumaN, lumaW), max(lumaS, lumaE)));

	float lumaRange = maxLuma - minLuma;

	if(lumaRange < max(FXAA_EDGE_THRESHOLD_MIN, maxLuma * FXAA_EDGE_THRESHOLD)) {
		gl_FragData[0] = vec4(color, 1.0);
		return;
	}
	
	// Sub-pixel Aliasing Test
	float lumaL = (lumaN + lumaW + lumaE + lumaS) * 0.25;
	float rangeL = abs(lumaL - lumaM);
	float blendL = max(0.0, (rangeL / lumaRange) - FXAA_SUBPIX_TRIM) * FXAA_SUBPIX_TRIM_SCALE;
	blendL = min(FXAA_SUBPIX_CAP, blendL);

	vec3 rgbL = rgbN + rgbW + rgbM + rgbE + rgbS;

	vec3 rgbNW = texture2D(colortex0, texcoord+vec2(-1., -1.)*inverseViewSize).rgb;
	vec3 rgbNE = texture2D(colortex0, texcoord+vec2(1., -1.)*inverseViewSize).rgb;
	vec3 rgbSW = texture2D(colortex0, texcoord+vec2(-1., -1.)*inverseViewSize).rgb;
	vec3 rgbSE = texture2D(colortex0, texcoord+vec2(1., -1.)*inverseViewSize).rgb;
	rgbL += (rgbNW + rgbNE + rgbSW + rgbSE);
	rgbL *= vec3(1./9.);

	float lumaNW = getLuma(rgbNW);
	float lumaNE = getLuma(rgbNE);
	float lumaSW = getLuma(rgbSW);
	float lumaSE = getLuma(rgbSE);

	// Vertical/Horizontal Edge Test
	float edgeVert =
		abs((0.25 * lumaNW) + (-0.5 * lumaN) + (0.25 * lumaNE)) +
		abs((0.50 * lumaW ) + (-1.0 * lumaM) + (0.50 * lumaE )) +
		abs((0.25 * lumaSW) + (-0.5 * lumaS) + (0.25 * lumaSE));
	float edgeHorz =
		abs((0.25 * lumaNW) + (-0.5 * lumaW) + (0.25 * lumaSW)) +
		abs((0.50 * lumaN ) + (-1.0 * lumaM) + (0.50 * lumaS )) +
		abs((0.25 * lumaNE) + (-0.5 * lumaE) + (0.25 * lumaSE));
	bool horizontalSpan = edgeHorz >= edgeVert;
	float lengthSign = horizontalSpan ? -inverseViewSize.y : -inverseViewSize.x;

	// this does something

	if(!horizontalSpan) lumaN = lumaW;
    if(!horizontalSpan) lumaS = lumaE;
    float gradientN = abs(lumaN - lumaM);
    float gradientS = abs(lumaS - lumaM);
    lumaN = (lumaN + lumaM) * 0.5;
    lumaS = (lumaS + lumaM) * 0.5;

	bool pairN = gradientN >= gradientS;
	if(!pairN) lumaN = lumaS;
	if(!pairN) gradientN = gradientS;
	if(!pairN) lengthSign *= -1.0;
	vec2 coordN;
	coordN.x = texcoord.x + (horizontalSpan ? 0.0 : lengthSign * 0.5);
	coordN.y = texcoord.y + (horizontalSpan ? lengthSign * 0.5 : 0.0);

	gradientN *= FXAA_SEARCH_THRESHOLD;

	// End-of-edge Search
	vec2 coordP = coordN;
	vec2 offsetNP = horizontalSpan ?
		vec2(inverseViewSize.x, 0.):
		vec2(0., inverseViewSize.y);
	float lumaEndN = lumaN;
	float lumaEndP = lumaN;
	bool doneN = false;
	bool doneP = false;

	coordN += offsetNP * vec2(-1., -1.);
	coordP += offsetNP * vec2(1., 1.);

	for(int i = 0; i < FXAA_SEARCH_STEPS; i++) {
		if(!doneN) lumaEndN =
			getLuma(texture2D(colortex0, coordN.xy).rgb);
		if(!doneP) lumaEndP =
			getLuma(texture2D(colortex0, coordP.xy).rgb);
		
		doneN = doneN || (abs(lumaEndN - lumaN) >= gradientN);
		doneP = doneP || (abs(lumaEndP - lumaN) >= gradientN);
		if(doneN && doneP) break;
		if(!doneN) coordN -= offsetNP;
		if(!doneP) coordP += offsetNP; 
	}

	// this works out what side the pixel is on and handles it
	float dstN = horizontalSpan ? texcoord.x - coordN.x : texcoord.y - coordN.y;
	float dstP = horizontalSpan ? coordP.x - texcoord.x: coordP.y - texcoord.y;
	bool directionN = dstN < dstP;
	lumaEndN = directionN ? lumaEndN : lumaEndP;

	if(((lumaM - lumaN) < 0.0) == ((lumaEndN - lumaN) < 0.0)) lengthSign = 0.0;

	float spanLength = (dstP + dstN);
	dstN = directionN ? dstN : dstP;
	float subPixelOffset = (0.5 + (dstN * (-1.0/spanLength))) * lengthSign;

	vec3 rgbF = texture2D(colortex0, vec2(
		texcoord.x + (horizontalSpan ? 0.0 : subPixelOffset),
		texcoord.y + (horizontalSpan ? subPixelOffset : 0.0))).rgb;

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(
		(vec3(-blendL) * rgbF) +
		((rgbL * vec3(blendL)) + rgbF), 1.0); //gcolor
#else
/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
#endif
}

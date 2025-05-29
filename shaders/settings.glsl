#define BLOCK_LIGHT_COLOR_R 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define BLOCK_LIGHT_COLOR_G 0.4 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define BLOCK_LIGHT_COLOR_B 0.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define BLOCK_LIGHT_BRIGHTNESS 0.3 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]


#define CUSTOM_SKY_COLOR 0 //[0 1]
#define SKY_LIGHT_COLOR_R 0.1 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0] 
#define SKY_LIGHT_COLOR_G 0.1 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define SKY_LIGHT_COLOR_B 0.1 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define SKY_LIGHT_BRIGHTNESS 1.5 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define AMBIENT 0.25 //[0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5]


#define SUN_LIGHT_COLOR_R  0.3 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0] 
#define SUN_LIGHT_COLOR_G  0.2 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0] 
#define SUN_LIGHT_COLOR_B  0.1 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0] 
#define SUN_LIGHT_BRIGHTNESS  1.5 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

#define SHADOWS_ENABLED 

#define SHADOW_BIAS 1.3 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]
#define SHADOW_DISTORT_FACTOR 0.1 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define SOFTEN_SHADOWS 3 //[0 1 2 3]
#define SHADOW_BRIGHTNESS 0.7 //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]

#define FXAA

const int shadowMapResolution = 1024; //[256 1024 2048 4096]
const int noiseTextureResolution = 1024;

#if SOFTEN_SHADOWS == 0
    const bool shadowtex1Nearest = false; 
    const bool shadowcolor0Nearest = false;
#else
    const bool shadowtex1Nearest = true; 
    const bool shadowcolor0Nearest = true;
#endif

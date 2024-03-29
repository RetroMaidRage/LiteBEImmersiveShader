#version 120
/*
const int colortex0Format = RGBA16F;
const int colortex1Format = RGB16;
const int colortex2Format = RGB16;
*/
//--------------------------------------------UNIFORMS------------------------------------------
#include "/files/filters/noises.glsl"
//#define UseTechFog
#ifdef UseTechFog
varying vec4 texcoord;
#else
varying vec4 texcoord
#endif
uniform sampler2D gcolor;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D composite;
uniform vec3 sunPosition;
uniform mat4 gbufferProjection;
uniform float worldTime;
uniform float rainStrength;
uniform float aspectRatio;
uniform float near;
uniform float far;
uniform sampler2D gaux1;
uniform vec3 fogColor;
uniform vec3 shadowLightPosition;
uniform float displayWidth;
uniform sampler2D noisetex;
uniform sampler2D colortex0;
varying vec3 sunVector;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;
uniform vec3 previousCameraPosition;
uniform vec3 skyColor;
uniform vec3 SkyPos;
uniform float frameTimeCounter;
uniform int isEyeInWater;
uniform mat4 gbufferModelView;
varying vec2 TexCoords;
//-----------------------------------------DEFINE------------------------------------------------
#define Fog
//#define GroundFog
#define FogDestiny 0.00015 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define GroundFogDestiny 0.015  ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define WaterFog
#define LavaFog
//-----------------------------------------------------------------------------------------------
float timefract = worldTime;
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);

vec3 sunsetFogColWorld = vec3(1.0,0.9,0.7); //2
vec3 nightFogColWorld = vec3(0.5,0.6,1.7); //2


vec3 sunsetFogColSun = vec3(0.5,0.6,1.7)+skyColor;
vec3 nightFogColSun = vec3(0.5,0.6,1.7)+skyColor;


vec3 WaterFogColor = vec3(0.2, 0.3, 0.5);
vec3 LavaFogColor = vec3(0.8, 0.66, 0.5);

vec3 customFogColorSun = (sunsetFogColSun*TimeSunrise + skyColor*TimeNoon + sunsetFogColSun*TimeSunset + nightFogColSun*TimeMidnight);
vec3 customFogColorWorld = (sunsetFogColWorld*TimeSunrise + skyColor*TimeNoon + sunsetFogColWorld*TimeSunset + nightFogColWorld*TimeMidnight);



//-----------------------------------------------------------------------------------------------
float     GetDepthLinear(in vec2 coord) {
   return 2.0f * near * far / (far + near - (2.0f * texture2D(depthtex0, coord).x - 1.0f) * (far - near));
}
//-----------------------------------------------------------------------------------------------
vec3 applyFog( in vec3  rgb, in float distance, in vec3  rayDir, in float coeff, in vec3  sunDir ) {

    float fogAmount = 1.0 - exp( -distance*coeff );
    float sunAmount = max(dot(rayDir, sunDir), 0.0);
    vec3  fogColor  = mix( customFogColorSun, customFogColorWorld, pow(sunAmount,1.0) );
    return mix( rgb, fogColor, fogAmount );

}


vec3 applyFog2( in vec3  rgb,      // original color of the pixel
               in float distance, // camera to point distance
               in vec3  rayDir,   // camera to point vector
               in vec3  sunDir,
                in float Fac,
                in float density )  // sun light direction
{

    float fogAmount = density*exp(-rayDir.y*0.07+Fac)*(1.0-exp(-distance*rayDir.y*0.07))/rayDir.y;
    //fogAmount += Fac;
    float sunAmount = max( dot( rayDir, sunDir ), 0.0 );
    vec3  fogColor  = mix( vec3(0.5,0.6,0.7)+(vec3(0.5,0.6,1.7)*TimeMidnight), // bluish
                           vec3(1.0,0.9,0.7), // yellowish
                           pow(sunAmount,7.0) );
    return mix( rgb, fogColor, fogAmount );
}
//----------------------------------------------------------------------------------------------
void main() {
  float depth = texture2D(depthtex0, texcoord.st).r;
    vec3 depth2 = texture2D(depthtex0, texcoord.st).rgb;
  bool isTerrain = depth < 1.0;
vec3 colorDepth = texture2D(gcolor, texcoord.st).rgb;
//----------------------------------------------------------------------------------------------
	vec3 screenPos = vec3(texcoord.st, texture2D(depthtex0, texcoord.st).r);
	vec3 clipPos = screenPos * 2.0 - 1.0;
	vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
	vec3 viewPos = tmp.xyz / tmp.w;
	vec4 world_position = gbufferModelViewInverse * vec4(viewPos, 1.0);
	vec3 P_world = (gbufferModelViewInverse * vec4(viewPos,1.0)).xyz + cameraPosition;
  //----------------------------------------------------------------------------------------------
	vec2 rainCoord = (P_world.xz/100000)+frameTimeCounter/10000;

	float Noise = texture2D(noisetex, fract(rainCoord.xy*8)).x;
	Noise += texture2D(noisetex, (rainCoord.xy*4)).x;
	Noise += texture2D(noisetex, (rainCoord.xy*2)).x;
	Noise += texture2D(noisetex, (rainCoord.xy/2)).x;

	float Fac = max(Noise-2.0,0.0);
//----------------------------------------------------------------------------------------------
	vec3 L = mat3(gbufferModelViewInverse) * normalize(shadowLightPosition.xyz);
//----------------------------------------------------------------------------------------------
float distancefog = length(depth2)*exp(depth2.y);

float distancefog2 = length(world_position.xyz);
vec3 fog = vec3(0);
vec3 rd = normalize(vec3(world_position.x,world_position.y,world_position.z));

float Depth = texture2D(depthtex0, TexCoords).r;
if(Depth == 1.0f){
		gl_FragData[0] = vec4(colorDepth, 1.0f);
		return;
}
//----------------------------------------------------------------------------------------------
vec3 color = texture2D(gcolor, texcoord.st).rgb;

float motion = simplex3d_fractal(P_world/30+pow(frameTimeCounter, 0.3));

vec3 density = vec3(smoothstep(0, 500.0, max(GetDepthLinear(texcoord.st)  / far, 1.0)))*20000;
vec3 density2 = vec3(smoothstep(0, 500.0, max(GetDepthLinear(texcoord.st)  / far, 1.0)))*20000;

#ifdef Fog
//color += applyFog(fog, distancefog,  rd, FogDestiny, L)*5;
#endif


color += applyFog2(fog, distancefog,  rd, L, motion, 10.5);

//color += applyFogGroundOver(fog, distancefogOver, normalize(cameraPosition), rd-Fac, L);
//----------------------------------------------------------------------------------------------
/* DRAWBUFFERS:02 */
	gl_FragData[0] = vec4(color.rgb, 1.0);
}

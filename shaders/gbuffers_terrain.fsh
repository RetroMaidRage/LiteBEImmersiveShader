#version 120
//----------------------------------------------------INCLUDE----------------------------------------------
#include "/files/filters/noises.glsl"

//----------------------------------------------------UNIFORMS----------------------------------------------
varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;
uniform sampler2D noisetex;
uniform float rainStrength;
uniform sampler2D texture;
varying vec4 texcoord;
in  float BlockId;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform float frameTimeCounter;
varying vec3 vworldpos;
varying vec3 SkyPos;
uniform mat4 gbufferModelViewInverse;
uniform vec3 shadowLightPosition;
varying vec3 viewPos;
varying vec3 upPosition;
varying vec4 vpos;
uniform int isEyeInWater;
flat in int BlockID;
uniform int worldTime;
uniform sampler2D gaux4;
//----------------------------------------------------DEF----------------------------------------------
#define specularTerrainStrenght 2 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define FakeCaustic
#define FakeCloudShadows

//#define Rain_Puddle_Old

#define PuddleStrenght 0.85 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]

//#define TerrainGradient
#define GradientStrenght 0.7 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define GradientTerrainStrenght 0.7 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]

//#define MoreLayer

//#define LeavesGradient
#define GradientLeavesStrenght 1 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]

//#define GrassGradient
#define GradientGrassStrenght 1 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]

#define GradientColorRed 0.5 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define GradientColorGreen 0.5 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define GradientColorBlue 0.5 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
//#define UseGradientColor

#define waveStrength 0.02; ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
//----------------------------------------------------CONST----------------------------------------------

//--------------------------------------------------------------------------------------------------------

void main(){
//--------------------------------------------------------------------------------------------------------

int id = int(BlockId + 0.5);
//----------------------------------------------------SPECULAR----------------------------------------------
  vec3 ShadowLightPosition = normalize(shadowLightPosition);
  vec3 NormalDir = normalize(Normal);
  vec3 lightDir = normalize(ShadowLightPosition);

  vec3 viewDir = -normalize(viewPos);
  vec3 halfDir = normalize(lightDir + viewDir);
  vec3 reflectDir = reflect(lightDir, viewDir);

  float SpecularAngle = pow(max(dot(halfDir, Normal), 0.0), 50);
  vec4 SpecularTexture = vec4(1.0, 1.0, 1.0,1.0);
//---------------------------------------------------CAUSIC-------------------------------------------------

//--------------------------------------------------------------------------------------------------------
vec4 Albedo = texture2D(texture, TexCoords) * Color;
//----------------------------------------FakeCloudShadows------------------------------------------------


//-------------------------------------------OUTPUT--------------------------------------------





//----------------------------------------SPECULAR--------------------------------------------------------
if (id == 10008.0 || id == 1) {

Albedo += (SpecularAngle*Albedo)*0.5;
if (id == 10008.0){
  Albedo += (SpecularAngle*Albedo)*1;
}
}else{
  if (id == 10010.0){
  Albedo += (SpecularAngle*Albedo)*rainStrength;
}
}


//--------------------------------------------------------------------------------------------------------
vec3 dayColor = texture2D(gaux4, vec2(float(worldTime) / 24000.0, 0.5)).rgb*LightmapCoords.x;
    /* DRAWBUFFERS:0126 */
//    Albedo.rgb*= dayColor;
    gl_FragData[0] = Albedo;
    gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
    //      gl_FragData[1] = vec4(-Normal * 0.5f + 0.5f, 1.0f);
    //    }
    gl_FragData[2] = vec4(LightmapCoords, 0.0f, 1.0f);
    gl_FragData[3] = vec4(float(BlockID) / 255, 0, 0, 1); //writing the block data to a buffer
}

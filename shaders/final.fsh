#version 120

#include "/files/tonemaps/tonemap_reinhard2.glsl"

uniform float viewHeight;
uniform float viewWidth;
varying vec2 TexCoords;
uniform vec3 sunPosition;
uniform mat4 gbufferProjection;
uniform sampler2D colortex0;
uniform float rainStrength;

#define COLORCORRECT_RED 1 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define COLORCORRECT_GREEN 1 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define COLORCORRECT_BLUE 1 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]

#define GammaSettings 2.2f  //[1.0f 1.1f 1.2f 1.3f 1.4f 1.5f 1.6f 1.7f 1.8f 1.9f 2.0f 3.0f 4.0f 5.0f 6.0f]

//#define TONEMAPPING
#define TonemappingType reinhard2 //[Uncharted2TonemapOp Aces reinhard2 lottes]

//#define CROSSPROCESS

//#define LensFlare
#define Desaturation

#define VanillaColors

//#define EasyBloom
#define EasyBloomSamples 2 //[2 4 6 8 10 12]

#ifdef LensFlare
vec3 lensflarer(vec2 uv,vec2 pos)
{
	vec2 main = uv-pos;
	vec2 uvd = uv*(length(uv));

	float ang = atan(main.y, main.x);
	float dist=length(main); dist = pow(dist,.1);






	float f2 = max(1.0/(1.0+32.0*pow(length(uvd+0.8*pos),2.0)),.0)*00.25;
	float f22 = max(1.0/(1.0+32.0*pow(length(uvd+0.85*pos),2.0)),.0)*00.23;
	float f23 = max(1.0/(1.0+32.0*pow(length(uvd+0.9*pos),2.0)),.0)*00.21;

	vec2 uvx = mix(uv,uvd,-0.5);

	float f4 = max(0.01-pow(length(uvx+0.4*pos),2.4),.0)*6.0;
	float f42 = max(0.01-pow(length(uvx+0.45*pos),2.4),.0)*5.0;
	float f43 = max(0.01-pow(length(uvx+0.5*pos),2.4),.0)*3.0;

	uvx = mix(uv,uvd,-.4);

	float f5 = max(0.01-pow(length(uvx+0.2*pos),5.5),.0)*2.0;
	float f52 = max(0.01-pow(length(uvx+0.4*pos),5.5),.0)*2.0;
	float f53 = max(0.01-pow(length(uvx+0.6*pos),5.5),.0)*2.0;

	uvx = mix(uv,uvd,-0.5);

	float f6 = max(0.01-pow(length(uvx-0.3*pos),1.6),.0)*6.0;
	float f62 = max(0.01-pow(length(uvx-0.325*pos),1.6),.0)*3.0;
	float f63 = max(0.01-pow(length(uvx-0.35*pos),1.6),.0)*5.0;

	vec3 c = vec3(.0);

	c.r+=f2+f4+f5+f6; c.g+=f22+f42+f52+f62; c.b+=f23+f43+f53+f63;


	return c;
}
#endif

void main() {
   vec3 color = pow(texture2D(colortex0, TexCoords).rgb, vec3(1.0f / GammaSettings));
	 vec3 color2 = pow(texture2D(colortex0, TexCoords).rgb, vec3(1.0f / GammaSettings));

   vec2 GetSreenRes = vec2(viewWidth, viewHeight);

   vec2 uv = gl_FragCoord.xy / GetSreenRes.xy - 0.5;
   uv.x *= GetSreenRes.x/GetSreenRes.y; //fix aspect ratio

   vec4 tpos = vec4(sunPosition,1.0)*gbufferProjection;
   tpos = vec4(tpos.xyz/tpos.w,1.0);
   vec2 LightPos = tpos.xy/tpos.z;
 //------------------------------------------------------------------------------------------------------------------
   #ifdef CROSSPROCESS
     color.r = (color.r*COLORCORRECT_RED);
       color.g = (color.g*COLORCORRECT_GREEN);
       color.b = (color.b*COLORCORRECT_BLUE);

     color = color / (color + 2.2) * (1.0+2.0);
   #endif
   //------------------------------------------------------------------------------------------------------------------
   #ifdef TONEMAPPING
     color = TonemappingType(color);
    #endif
//------------------------------------------------------------------------------------------------------------------
#ifdef EasyBloom
vec4 bloom = vec4(0,0,0,0);
		for (int i = 1; i < EasyBloomSamples; i++){
		        bloom += textureLod(colortex0, TexCoords, float(i)) / float(i);

		    color.rgb += bloom.rgb * 0.02;
				color2.rgb += bloom.rgb * 0.02;
}
#endif
//------------------------------------------------------------------------------------------------------------------
#ifdef LensFlare
  if (sunPosition.z < 0){
      //color.rgb+=lensflarer(uvv,LightPos)/2;
    }
#endif
//------------------------------------------------------------------------------------------------------------------
#ifdef Desaturation

     float Fac = 0.0;
     Fac = 0.3*clamp(rainStrength, 0.0, 1.0);

vec3 gray = vec3( dot( color2.rgb , vec3( 0.2126 , 0.7152 , 0.0722 )));
color2 = vec3( mix( color2.rgb , gray , Fac)  );


#endif

#ifdef VanillaColors

   gl_FragColor = vec4(color2, 1.0f);
#else
 gl_FragColor = vec4(color, 1.0f);
 #endif
}

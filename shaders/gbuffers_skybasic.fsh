#version 120
#define skybasic
#ifdef skybasic
uniform float viewHeight;
uniform float viewWidth;
#else
uniform float viewHeight
uniform float viewWidth
#endif
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 upPosition;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform vec3 shadowLightPosition;
varying vec3 SkyPos;
uniform int worldTime;

varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.
//-------------------------------------------------------------------------------------
vec3 viewVec = normalize(SkyPos);
vec3 horizonVec = normalize(upPosition+viewVec);
vec3 SunVector = normalize(sunPosition+viewVec);
vec3 SunNormalise = normalize(sunPosition);
vec3 MoonVector = normalize(moonPosition+viewVec);
vec3 LightVector = normalize(moonPosition+viewVec);
float VectorSky = dot(shadowLightPosition, viewVec);
float horizon = dot(horizonVec, viewVec);
//-------------------------------------------------------------------------------------
float fogify(float x, float w) {
	return w / (x * x + w);
}
vec3 mie(float dist, vec3 sunL){
return max(exp(-pow(dist, 0.55)) * sunL - 0.2, 0.0);
}

float Rayleigh(float costh){
return 3.0 / (16.0 * 3.14 ) * (1.0 + costh * costh);
}

vec3 calcSkyColor(vec3 pos) {

	float upDot = dot(pos, gbufferModelView[1].xyz);


vec3 skyColorFinal = mix(skyColor, fogColor*1.2, fogify(max(upDot, horizon), 0.055));
	return skyColorFinal;
}
//-------------------------------------------------------------------------------------
void main() {
	vec3 color;
	if (starData.a > 0.5) {
		color = starData.rgb*2;
	}
	else {
		vec4 pos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
		pos = gbufferProjectionInverse * pos;
		color = calcSkyColor(normalize(pos.xyz));

		float sunDistance = distance(viewVec, clamp(SunVector, -1.0, 1.0));
		 sunDistance = distance(viewVec, clamp(SunVector, -1.0, 1.0));

    float cosTheta = dot(viewVec, normalize(sunPosition));
		vec3 mieScatter = mie(sunDistance, vec3(0.25));
		color+=mieScatter;

		float p = Rayleigh(cosTheta);
	//	color += p;

	}

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}

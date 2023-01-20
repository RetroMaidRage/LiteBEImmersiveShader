#version 120

//--------------------------------------------------------------------------------------------
varying vec4 texcoord;
uniform sampler2D lightmap;
uniform sampler2D texture;
varying vec3 Normal;
varying vec2 lmcoord;
varying vec2 LightmapCoords;
varying vec4 glcolor;
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------
void main() {

vec4 color = texture2D(texture, texcoord.st) *glcolor;

//--------------------------------------------------------------------------------------------

/* DRAWBUFFERS:012 */

	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
	gl_FragData[2] = vec4(LightmapCoords, 0.0f, 1.0f);

}

//СДЕЛАТЬ НВОЫЙ ДОЖДЬ

#version 120

//--------------------------------------------------------------------------------------------
varying vec4 texcoord;
uniform sampler2D texture;
varying vec3 Normal;
varying vec4 glcolor;
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------
void main() {

vec4 color = texture2D(texture, texcoord.st) *glcolor;

//--------------------------------------------------------------------------------------------

/* DRAWBUFFERS:07 */

	gl_FragData[0] = color; //gcolor
		gl_FragData[1] = vec4(10.0f); //gcolor


}

#version 120

uniform sampler2D texture;

varying vec2 texcoord;
varying vec4 glcolor;
uniform float wetness;
uniform float rainStrength;

void main() {
	float Raining = clamp(wetness, 0.0, 1.0);
	vec4 color = texture2D(texture, texcoord);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}

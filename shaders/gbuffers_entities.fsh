#version 120

uniform sampler2D lightmap;
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;
uniform vec4 entityColor;

uniform sampler2D texture;

void main(){

    vec4 Albedo = texture2D(texture, texcoord) * Color;
		vec4 color = texture2D(texture, texcoord) * glcolor;
		color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
  /* DRAWBUFFERS:023 */

		gl_FragData[0] = color;
   gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
   gl_FragData[2] = vec4(LightmapCoords, 0.0f, 1.0f);
}

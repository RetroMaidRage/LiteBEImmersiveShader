#version 120

varying vec2 texcoord;
varying vec4 glcolor;
varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;
uniform vec4 entityColor;
flat in int entID;
uniform sampler2D texture;

void main(){

  vec4 albedo  = texture2D(texture, texcoord) * glcolor;

  // render thunder
  if(entID == 1.0){
     albedo.a = 0.15;
 
  }

    /* DRAWBUFFERS:012 */
  // render entity color changes (e.g taking damage)
  albedo.rgb = mix(albedo.rgb, entityColor.rgb, entityColor.a);

	gl_FragData[0] = albedo;
   gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
   gl_FragData[2] = vec4(LightmapCoords, 0.0f, 1.0f);
}

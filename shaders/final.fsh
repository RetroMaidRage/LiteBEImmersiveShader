#version 120

varying vec2 TexCoords;

uniform sampler2D colortex0;

#define COLORCORRECT_RED 1 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define COLORCORRECT_GREEN 1 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define COLORCORRECT_BLUE 1 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]

#define TONEMAPPING
#define CROSSPROCESS



void main() {
   vec3 color = pow(texture2D(colortex0, TexCoords).rgb, vec3(1.0f / 2.2f));

   #ifdef CROSSPROCESS
     color.r = (color.r*COLORCORRECT_RED);
       color.g = (color.g*COLORCORRECT_GREEN);
       color.b = (color.b*COLORCORRECT_BLUE);

     color = color / (color + 2.2) * (1.0+2.0);
   #endif
   //------------------------------------------------------------------------------------------------------------------


   gl_FragColor = vec4(color, 1.0f);
}

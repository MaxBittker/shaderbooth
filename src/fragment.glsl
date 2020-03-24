precision mediump float;

varying vec2 uv;
uniform float time;
uniform vec2 resolution;
uniform vec2 videoResolution;
uniform vec2 scaledVideoResolution;
uniform sampler2D camTex;
uniform sampler2D maskTex;
uniform sampler2D previousTex;

#define PI 3.14159265359
vec2 pixel = 1.0 / resolution;

void main() {
  vec2 resRatio = scaledVideoResolution / resolution;
  vec2 webcamCoord = (uv / resRatio) / 2.0 + vec2(0.5);

  vec2 flipwcord = vec2(1.) - webcamCoord;
  vec2 backCoord = uv *0.99;
  backCoord = (backCoord / 2.0) + vec2(0.5);

  vec3 cam = texture2D(camTex, flipwcord).rgb;
  vec3 previous = texture2D(previousTex, backCoord).rgb;
  vec4 mask = texture2D(maskTex, flipwcord).rgba;

  float face = mask.b; // face features are encoded as colors 
  float eye = mask.g;
  float mouth = mask.r;

  vec3 color = cam;
  // try uncommenting this line:
  color= previous;

  if (face > 0.2) {
    color = cam * 0.9 + mask.rgb * 0.6;
  }
  if (eye > mod(time,1.5)) {
    color = cam;
  }
  if (mouth > 0.6) {
    color = cam;
  }

  gl_FragColor = vec4(color, 1);
}
precision mediump float;

uniform float time;
uniform vec2 resolution;
uniform sampler2D camTex;
uniform sampler2D previousTex;
uniform sampler2D maskTex;
uniform vec2 videoResolution;
uniform vec2 scaledVideoResolution;
varying vec2 uv;

#define PI 3.14159265359
vec2 pixel = 1.0 / resolution;

void main() {
  vec2 resRatio = scaledVideoResolution / resolution;
  vec2 webcamCoord = (uv / resRatio) / 2.0 + vec2(0.5);

  vec2 flipwcord = vec2(1.) - webcamCoord;
  vec2 backCoord = uv * (1.0 + 0.00);
  backCoord = (backCoord / 2.0) + vec2(0.5);

  vec3 cam = texture2D(camTex, flipwcord).rgb;
  vec3 previous = texture2D(previousTex, backCoord).rgb;
  vec4 mask = texture2D(maskTex, flipwcord).rgba;

  vec3 color = cam;

  float face = mask.b;
  float eye = mask.g;
  float mouth = mask.r;

  if (face > 0.2) {
    color = cam * 0.2 + mask.rgb * 0.8;
  }
  if (eye > 0.4) {
  }
  if (mouth > 0.6) {
  }

  gl_FragColor = vec4(color, 1);
}
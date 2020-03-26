module.exports = `precision mediump float;

varying vec2 uv;
uniform float time;
uniform vec2 resolution;
uniform vec2 videoResolution;
uniform vec2 scaledVideoResolution;
uniform sampler2D camTex;
uniform sampler2D maskTex;
uniform sampler2D previousTex;
vec2 pixel = 1.0 / resolution;
vec3 getCam(vec2 pos) {
  vec2 resRatio = scaledVideoResolution / resolution;
  vec2 webcamCoord = (pos / resRatio) / 2.0 + vec2(0.5);
  vec2 flipwcord = vec2(1.) - webcamCoord;
  return texture2D(camTex, flipwcord).rgb;
}

vec3 getPrevious(vec2 pos) {
  vec2 backCoord = (pos / 2.0) + vec2(0.5);
  return texture2D(previousTex, backCoord).rgb;
}

float getFace(vec2 pos) {
  vec2 resRatio = scaledVideoResolution / resolution;
  vec2 webcamCoord = (pos / resRatio) / 2.0 + vec2(0.5);
  vec2 flipwcord = vec2(1.) - webcamCoord;
  return texture2D(maskTex, flipwcord).b;
}
float getEye(vec2 pos) {
  vec2 resRatio = scaledVideoResolution / resolution;
  vec2 webcamCoord = (pos / resRatio) / 2.0 + vec2(0.5);
  vec2 flipwcord = vec2(1.) - webcamCoord;
  return texture2D(maskTex, flipwcord).g;
}
float getMouth(vec2 pos) {
  vec2 resRatio = scaledVideoResolution / resolution;
  vec2 webcamCoord = (pos / resRatio) / 2.0 + vec2(0.5);
  vec2 flipwcord = vec2(1.) - webcamCoord;
  return texture2D(maskTex, flipwcord).r;
}`;

precision mediump float;
uniform float tick;
uniform float time;
uniform bool hasFace;
uniform vec2 resolution;
uniform sampler2D backBuffer;
uniform sampler2D webcam;
uniform sampler2D faceDetection;
uniform vec2 videoResolution;
uniform vec2 scaledVideoResolution;
varying vec2 uv;

#define PI 3.14159265359
vec2 pixel = 1.0 / resolution;

void main() {
  vec2 uvN = (uv * 0.5) + vec2(0.5);
  vec2 resRatio = scaledVideoResolution / resolution;
  vec2 webcamCoord = (uv / resRatio) / 2.0 + vec2(0.5);

  vec2 flipwcord = vec2(1.) - webcamCoord;
  vec2 backCoord = uv * (1.0 + 0.00);
  backCoord = (backCoord / 2.0) + vec2(0.5);

  vec3 webcamColor = texture2D(webcam, flipwcord).rgb;
  vec3 backBufferColor = texture2D(backBuffer, backCoord).rgb;
  vec4 facePaintColor = texture2D(faceDetection, flipwcord).rgba;

  vec3 color = webcamColor;

  float face = facePaintColor.b;
  float eye = facePaintColor.g;
  float mouth = facePaintColor.r;

  if (face > 0.2) {
    color = webcamColor * 0.2 + facePaintColor.rgb * 0.8;
    // color = backBufferColor;
  }
  if (eye > 0.4) {
    // color = webcamColor;
    // color = vec3(1.0, 0., 0.) + webcamColor;
  }
  if (mouth > 0.6) {
    // color = webcamColor;
  }

  gl_FragColor = vec4(color, 1);
}
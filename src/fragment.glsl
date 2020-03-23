precision highp float;
uniform float tick;
uniform float time;
uniform bool hasFace;
uniform vec2 resolution;
uniform sampler2D backBuffer;
uniform sampler2D webcam;
uniform sampler2D faceDetection;
uniform vec2 videoResolution;
uniform vec2 scaledVideoResolution;
// uniform vec2 eyes[2];

varying vec2 uv;

// clang-format off
#pragma glslify: squareFrame = require("glsl-square-frame")
#pragma glslify: worley2D = require(glsl-worley/worley2D.glsl)
#pragma glslify: hsv2rgb = require('glsl-hsv2rgb')
#pragma glslify: luma = require(glsl-luma)
#pragma glslify: smin = require(glsl-smooth-min)
#pragma glslify: fbm3d = require('glsl-fractal-brownian-noise/3d')
#pragma glslify: noise = require('glsl-noise/simplex/3d')

// clang-format on
#define PI 3.14159265359

void main() {
  vec2 uvN = (uv * 0.5) + vec2(0.5);
  vec2 resRatio = scaledVideoResolution / resolution;
  vec2 pixel = 1.0 / resolution;
  vec2 webcamCoord = uv / resRatio;

  webcamCoord /= 2.0;
  webcamCoord += vec2(0.5);

  vec2 flipwcord = vec2(1.) - webcamCoord;
  vec2 backCoord = uv * (1.0 + 0.01);
  backCoord /= 2.0;
  backCoord += vec2(0.5);
  vec3 webcamColor = texture2D(webcam, flipwcord).rgb;

  vec3 backBufferColor = texture2D(backBuffer, backCoord).rgb;
  vec4 facePaintColor = texture2D(faceDetection, flipwcord).rgba;
  vec3 color = webcamColor;

  float face = facePaintColor.b;
  float eye = facePaintColor.g;
  float mouth = facePaintColor.r;
  // color = webcamColor * 0.5 + facePaintColor.rgb * 0.5;
  // color = webcamColor * 0.8 + facePaintColor.rgb * 0.5;

  if (face > 0.3) {
    color = webcamColor * 0.2 + facePaintColor.rgb * 0.8;

    //   color = webcamColor;
  }
  // if (eye > 0.4) {
  //   // color = webcamColor;

  //   // color = vec3(1.0, 0., 0.) + webcamColor;
  // }
  if (mouth > 0.6) {
    // color = webcamColor;
  }
  // // color = facePaintColor.rgb + webcamColor;
  if (!hasFace) {
    float scanLine = mod(time * 0.5, 1.0);
    if (abs(uvN.x - scanLine) < pixel.x * 1.) {
      color += vec3(0., 1.0, 0.) *
               (0.5 + max(sin(uvN.y * 200. + time * 2.0), 0.0) * 0.5);
    }
    color.g = color.g * 0.5 + backBufferColor.g * 0.5;
  }
  gl_FragColor = vec4(color, 1);
}
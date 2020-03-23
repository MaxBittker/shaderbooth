const regl = require("regl")("#target", { pixelRatio: 0.75 });
const { setupWebcam } = require("./src/setup-facemesh.js");
let shaders = require("./src/pack.shader.js");
let loadingShader = `precision mediump float;
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
  vec2 backCoord = uv * (1.0 + 0.01);
  backCoord = (backCoord / 2.0) + vec2(0.5);
  vec3 webcamColor = texture2D(webcam, flipwcord).rgb;
  vec3 backBufferColor = texture2D(backBuffer, backCoord).rgb;
  vec4 facePaintColor = texture2D(faceDetection, flipwcord).rgba;
  vec3 color = webcamColor;

  if (!hasFace) {
    float scanLine = mod(time * 0.5, 1.0);
    if (abs(uvN.x - scanLine) < pixel.x * 1.) {
      color += vec3(0., 1.0, 0.) *
               (0.5 + max(sin(uvN.y * 200. + time * 2.0), 0.0) * 0.5);
    }
    color.g = color.g * 0.5 + backBufferColor.g * 0.5;
  }
  gl_FragColor = vec4(color, 1);
}`;
// require("./src/scanningShader.glsl");
let { paintFace } = require("./src/paint");
const Editor = require("./src/editor.js");

var editor = new Editor();
// let vert = shaders.vertex;
// let frag = shaders.fragment;
let knownGoodShader = shaders.fragment;

// shaders.on("change", () => {
//   console.log("update");
//   vert = shaders.vertex;
//   frag = shaders.fragment;
//   // editor.setValue(frag);

//   // let overlay = document.getElementById("regl-overlay-error");
//   // overlay && overlay.parentNode.removeChild(overlay);
// });
editor.setValue(shaders.fragment);
editor.cm.on("change", c => {
  console.log(c);
  let newShader = editor.getValue();
  shaders.fragment = newShader;
});
const lastFrame = regl.texture();

let paintElement = document.getElementById("paint"); //.getContext("2d");
let faceDetectionTexture;

let hasFace = false;
setupWebcam({
  regl,
  done: (webcam, { videoWidth, videoHeight, getKeyPoints }) => {
    faceDetectionTexture = regl.texture(paintElement);
    // faceDetectionTexture.resize(videoWidth, videoHeight);

    let drawTriangle = regl({
      uniforms: {
        webcam,
        videoResolution: [videoWidth, videoHeight],
        // Becomes `uniform float t`  and `uniform vec2 resolution` in the shader.
        tick: ({ tick }) => tick,
        time: ({ time }) => time,
        hasFace: () => hasFace,
        resolution: ({ viewportWidth, viewportHeight }) => [
          viewportWidth,
          viewportHeight
        ],
        scaledVideoResolution: ({ viewportWidth: vW, viewportHeight: vH }) => {
          let i;
          return (i =
            vW / vH > videoWidth / videoHeight
              ? [videoWidth * (vH / videoHeight), vH]
              : [vW, videoHeight * (vW / videoWidth)]);
        },
        backBuffer: lastFrame,
        faceDetection: faceDetectionTexture
      },

      frag: () => (hasFace ? shaders.fragment : loadingShader),
      vert: () => shaders.vertex,
      attributes: {
        // Full screen triangle
        position: [
          [-1, 4],
          [-1, -1],
          [4, -1]
        ]
      },
      // Our triangle has 3 vertices
      count: 3
    });

    regl.frame(function(context) {
      let keyPoints = getKeyPoints();
      // regl.clear({
      //   color: [0, 0, 0, 1]
      // });
      if (keyPoints) {
        hasFace = true;
        ctx = paintFace(keyPoints);
        faceDetectionTexture.subimage(ctx);
      }
      try {
        drawTriangle();
      } catch (e) {
        console.log(e);
        // debugger;
        // editor.flashCode(100, 200);
        shaders.fragment = knownGoodShader;

        return;
      }
      knownGoodShader = shaders.fragment;

      lastFrame({
        copy: true
      });
    });
  }
});

const regl = require("regl")("#target", { pixelRatio: 0.75 });
const { setupWebcam } = require("./src/setup-facemesh.js");
let shaders = require("./src/pack.shader.js");
let loadingShader = require("./src/loadingShader.js");
let { paintFace } = require("./src/paint");
const Editor = require("./src/editor.js");

var editor = new Editor();
let knownGoodShader = shaders.fragment;

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
        camTex: webcam,
        previousTex: lastFrame,
        maskTex: faceDetectionTexture,
        videoResolution: [videoWidth, videoHeight],
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
        }
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

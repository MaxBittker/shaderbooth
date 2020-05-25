const regl = require("regl")("#target", { pixelRatio: 0.75 });
const { setupWebcam } = require("./src/setup-facemesh.js");
let shaders = require("./src/pack.shader.js");
let handleActivity = require("./src/fade.js");
let buildReference = require("./src/reference.js");
let share = require("./src/share.js");
let fs = require("fs");
let loadingShader = fs.readFileSync(__dirname + "/src/loadingShader.glsl");
let prefix = fs.readFileSync(__dirname + "/src/prefix.glsl").toString();
let demos = fs.readdirSync(__dirname + "/demos");
let previousDemo = document.getElementById("prev");
let nextDemo = document.getElementById("next");

let demoIndex = demos.indexOf("starter.glsl");

let { paintFace } = require("./src/paint");
const Editor = require("./src/editor.js");

var editor = new Editor();

const serverAddr = "https://api.shaderbooth.com:3002/";
function loadShaderFromServer() {
  if (window.location.search.length > 2) {
    let id = window.location.search.slice(1);
    fetch(serverAddr + "static/" + id)
      .then(response => {
        if (response.status == 200) {
          return response.text();
        } else {
          alert("I couldnt' find that sketch");
        }
      })
      .then(data => {
        let code = JSON.parse(data);
        console.log(code);
        editor.setValue(code);
      });
  }
}
loadShaderFromServer();
let shareButton = document.getElementById("share");
shareButton.addEventListener("click", () => {
  fetch(serverAddr + "upload/", {
    method: "post",
    body: JSON.stringify(editor.getValue())
  })
    .then(function(response) {
      return response.json();
    })
    .then(function({ id }) {
      window.history.pushState({}, "Shaderbooth", "?" + id);
      document.getElementById("url-copy").value = "Shaderbooth.com/?" + id;
      loadShaderFromServer();
    });
});

function replaceShader() {
  let file = demos[demoIndex];
  fetch("./demos/" + file)
    .then(response => {
      return response.text();
    })
    .then(data => {
      editor.setValue(data);
    });
}
replaceShader();
previousDemo.addEventListener("click", () => {
  demoIndex = (demoIndex + demos.length - 1) % demos.length;
  replaceShader();
});
nextDemo.addEventListener("click", () => {
  demoIndex = (demoIndex + 1) % demos.length;
  replaceShader();
});

shaders.fragment = shaders.fragment.replace(
  `#define GLSLIFY 1
`,
  ""
);
let knownGoodShader = shaders.fragment;

let prefixLength = prefix.split(/\r\n|\r|\n/).length - 1;
let widgets = [];
let markers = [];
function clearHints(errors) {
  editor.cm.operation(function() {
    for (var i = 0; i < widgets.length; ++i) {
      editor.cm.removeLineWidget(widgets[i]);
    }
    widgets.length = 0;

    for (var i = 0; i < markers.length; ++i) {
      markers[i].clear();
    }
    markers.length = 0;
  });
}

function displayError(line, offset, message, token) {
  line = line - prefixLength;
  var msg = document.createElement("div");
  if (widgets.some(widget => widget["_line_number"] == line)) {
    return;
  }
  msg.appendChild(
    document.createTextNode(
      ("^" + message).padStart(offset + message.length + 1, "\xa0")
    )
  );
  msg.className = "lint-error fade";
  let lineWidget = editor.cm.addLineWidget(line - 1, msg, {
    coverGutter: false,
    noHScroll: true
  });
  lineWidget["_line_number"] = line;
  widgets.push(lineWidget);
  markers.push(
    editor.cm.markText(
      { line: line - 1, ch: offset },
      { line: line - 1, ch: offset + token.length },
      { className: "cm-custom-error", attributes: { alt: message } }
    )
  );
}

// this relies on a special forked regl.
window.shader_error_hook = displayError;
editor.setValue(shaders.fragment);

editor.cm.on("change", c => {
  let newShader = editor.getValue();
  shaders.fragment = newShader;
  clearHints();
});
const lastFrame = regl.texture();

let paintElement = document.getElementById("paint"); //.getContext("2d");
let faceDetectionTexture;

let hasFace = false;

let faceCenter = [0.5, 0.5];

function convertCoordinate([fx, fy], videoWidth, videoHeight) {
  x = fx / videoWidth;
  y = fy / videoHeight;
  x = 1 - x;
  y = 1 - y;
  x = 2 * x - 1.0;
  y = 2 * y - 1.0;
  let targetAspect = window.innerWidth / window.innerHeight;
  let videoAspect = videoWidth / videoHeight;
  let uvA_x = x / (targetAspect / videoAspect);
  let uvA_y = y;
  if (targetAspect < videoAspect) {
    uvA_x = x;
    uvA_y = y / (videoAspect / targetAspect);
  }

  return [uvA_x, uvA_y];
}
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
        time: ({ time }) => time % 10000,
        hasFace: () => hasFace,
        resolution: ({ viewportWidth, viewportHeight }) => [
          viewportWidth,
          viewportHeight
        ],
        targetAspect: () => window.innerWidth / window.innerHeight,
        scaledVideoResolution: ({ viewportWidth: vW, viewportHeight: vH }) => {
          let i;
          i =
            vW / vH > videoWidth / videoHeight
              ? [videoWidth * (vH / videoHeight), vH]
              : [vW, videoHeight * (vW / videoWidth)];
          return i;
        },
        faceCenter: () =>
          convertCoordinate(faceCenter, videoWidth, videoHeight),
        leftEye: () =>
          convertCoordinate(window.leftEye, videoWidth, videoHeight),
        rightEye: () =>
          convertCoordinate(window.rightEye, videoWidth, videoHeight)
      },

      frag: () => (hasFace ? prefix + shaders.fragment : loadingShader),
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
        faceCenter = keyPoints.noseTip[0];
        // console.log(faceCenter[0]);
        // console.log(keyPoints.midwayBetweenEyes);
        // debugger;
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

// let { TRIANGULATION } = require("./triangulation");
let hull = require("hull.js");
let canvas = document.getElementById("paint");

ctx = canvas.getContext("2d");
ctx.translate(canvas.width, 0);
ctx.scale(-1, 1);

function drawShape(points) {
  ctx.beginPath();

  for (let i = 0; i < points.length; i++) {
    const x = points[i][0];
    const y = points[i][1];

    if (i == 0) {
      ctx.moveTo(x, y);
    } else {
      ctx.lineTo(x, y);
    }
  }

  ctx.closePath();
  ctx.stroke();
  ctx.fill();
}
function paintFace(annotations) {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.lineCap = "round";

  let silhouette = annotations["silhouette"];
  let convexsilhouette = hull(silhouette, 1000);
  ctx.fillStyle = `#008`;
  ctx.strokeStyle = `#004`;
  ctx.lineWidth = 2;
  drawShape(convexsilhouette);
  ctx.lineWidth = 0;
  ctx.strokeStyle = "rgba(1, 1, 1, 0)";

  let leftEyebrow = [
    ...annotations["leftEyebrowLower"],
    ...annotations["leftEyebrowUpper"]
  ];

  let rightEyebrow = [
    ...annotations["rightEyebrowLower"],
    ...annotations["rightEyebrowUpper"]
  ];

  ctx.fillStyle = `#048`;
  drawShape(hull(leftEyebrow, 20));
  drawShape(hull(rightEyebrow, 20));

  let leftEye2 = [
    ...annotations["leftEyeLower2"],
    ...annotations["leftEyeUpper2"]
  ];

  let rightEye2 = [
    ...annotations["rightEyeLower2"],
    ...annotations["rightEyeUpper2"]
  ];
  ctx.fillStyle = `#088`;
  drawShape(hull(leftEye2, 1000));
  drawShape(hull(rightEye2, 1000));

  let leftEye1 = [
    ...annotations["leftEyeLower1"],
    ...annotations["leftEyeUpper1"]
  ];

  let rightEye1 = [
    ...annotations["rightEyeLower1"],
    ...annotations["rightEyeUpper1"]
  ];
  ctx.fillStyle = `#0C8`;
  drawShape(hull(leftEye1, 1000));
  drawShape(hull(rightEye1, 1000));

  let leftEye0 = [
    ...annotations["leftEyeLower0"],
    ...annotations["leftEyeUpper0"]
  ];

  let rightEye0 = [
    ...annotations["rightEyeLower0"],
    ...annotations["rightEyeUpper0"]
  ];
  ctx.fillStyle = `#0f8`;
  drawShape(hull(leftEye0, 1000));
  drawShape(hull(rightEye0, 1000));

  let outerMouth = [
    ...annotations["lipsUpperOuter"],
    ...annotations["lipsLowerOuter"]
  ];
  ctx.fillStyle = `#808`;
  let outerMouthHull = hull(outerMouth, 1000);
  drawShape(outerMouthHull);

  let innerMouth = [
    ...annotations["lipsUpperInner"],
    ...annotations["lipsLowerInner"]
  ];
  ctx.fillStyle = `#F08`;
  let innerMouthHull = hull(innerMouth, 1000);
  drawShape(innerMouthHull);

  let nosePath = [
    ...annotations["noseBottom"],
    ...annotations["noseTip"],
    ...annotations["noseLeftCorner"],
    ...annotations["midwayBetweenEyes"],
    ...annotations["noseRightCorner"]
  ];
  let convexNosePath = hull(nosePath, 1000);
  ctx.fillStyle = `#00F`;
  ctx.strokeStyle = `#00C`;
  ctx.lineWidth = 2;
  drawShape(convexNosePath);

  return ctx;
}
module.exports = { paintFace };

/*
cheekStuff(){

  let [x1, y1, z1] = annotations["leftCheek"][0];
  [x2, y2, z2] = annotations["rightCheek"][0];
  let cheekDistance = Math.sqrt(
    Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2) + Math.pow(z1 - z2, 2)
  );

  ctx.beginPath();
  ctx.lineWidth = 0.5;
  ctx.arc(x1, y1, cheekDistance * 0.05 , 0, 2 * Math.PI);
  ctx.fill();

  ctx.beginPath();
  ctx.lineWidth = 0.5;
  ctx.arc(x2, y2, cheekDistance * 0.05 , 0, 2 * Math.PI);
  ctx.fill();
}*/

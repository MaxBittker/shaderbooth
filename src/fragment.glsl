void main() {

  vec3 cam = getCam(uv);
  vec3 prev = getPrevious(uv * 1.05 + pixel * 20.);

  float face = getFace(uv);
  float eye = getEye(uv);
  float mouth = getMouth(uv);

  vec3 color = cam;

  // try uncommenting this line:
  // color = getPrevious(uv + (cam.rg-cam.bb)*0.1);

  if (face > 0.2) {
    // or this one
    color = getPrevious(uv * 1.4);
  }

  // eye black
  if (eye > 0.3) {
    color = vec3(0.);
  }
  if (eye > 0.6) {
    color = cam;
  }
  // lipstick
  if (mouth > 0.4) {
    color = cam * vec3(1.0, 0.0, .0);
  }
  if (mouth > 0.6) {
    color = cam;
  }
  if (max(abs(uv.x), abs(uv.y)) > 0.95) {
    color = cam;
  }
  gl_FragColor = vec4(color, 1);
}

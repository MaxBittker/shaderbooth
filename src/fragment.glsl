
void main() {

  vec3 cam = getCam(uv);
  vec3 prev = getPrevious(uv + pixel * 20.);

  float face = getFace(uv);
  float eye = getEye(uv);
  float mouth = getMouth(uv);
  vec3 mask = vec3(mouth, eye, face);

  vec3 color = cam;

  // try uncommenting this line:
  // color = prev;

  if (face > 0.2) {
    color = mask * cam * 2.;
  }
  if (eye > 0.8) {
    color = cam;
  }
  if (mouth > 0.6) {
    color = cam;
  }

  gl_FragColor = vec4(color, 1);
}
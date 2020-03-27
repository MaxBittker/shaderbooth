void main() {

  vec3 cam = getCam(uv);
  vec3 prev = getPrevious(uv * 1.05 + pixel * 20.);
  float face = getFace(uv);

  vec3 color = cam;

  // try uncommenting this line:
  color = getPrevious(uv + (cam.rg - cam.bb) * 0.1);
  if (getFace(uv) > 0.2) {
    color = cam;
  }
  float offset = 0.4;
  //   offset *= sin(time*2.);
  if (getFace(uv - vec2(offset, 0.)) > face) {
    color = getCam(uv - vec2(offset, 0.));
  }

  offset *= -1.;
  if (getFace(uv - vec2(offset, 0.)) > face) {
    color = getCam(uv - vec2(offset, 0.));
  }

  gl_FragColor = vec4(color, 1);
}

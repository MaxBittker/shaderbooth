void main() {

  vec3 color = getCam(uv);

  // try uncommenting this line:
  // color = getPrevious(uv + (color.rg - color.bb) * 0.1);

  float distToCenter = length(uv - faceCenter);
  int faceHit = 0;
  for (int i = 0; i < 20; i++) {
    float a = time + TAU * float(i) / 20.;
    vec2 offset = vec2(sin(a), cos(a));
    offset *= 2.5 * distToCenter;
    vec2 pos = uv * 4.;
    if (getFace(pos - offset) > 0.1) {
      faceHit = 1;
      color = getCam(pos - offset);
    }
  }

  if (faceHit == 0) {
    color = getPrevious(uv * 1.03) * .9;
  }
  // color = vec3(0.0);
  gl_FragColor = vec4(color, 1);
}

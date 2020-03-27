void main() {

  vec3 color = getCam(uv);

  vec2 pos = uv;
  pos.y -= 0.3;
  pos /= 2.4;
  if (getMouth(pos) > 0.3) {
    color = getCam(pos);
  }

  pos.y += 0.3;
  if (getEye(pos) > 0.6) {
    // big eyes:
    // color = getCam(pos);
  }

  gl_FragColor = vec4(color, 1);
}

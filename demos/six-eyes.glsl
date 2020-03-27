void main() {

  vec3 cam = getCam(uv);
  vec3 color = cam;

  float offset = 0.1;

  if (getEye(uv - vec2(0., offset)) > 0.6) {
    color = getPrevious(uv - vec2(0, +offset * 2.));
  }
  offset = -0.10;

  if (getEye(uv - vec2(0., offset)) > 0.6) {
    color = getPrevious(uv - vec2(0, offset));
  }

  gl_FragColor = vec4(color, 1);
}

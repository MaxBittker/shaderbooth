

void main() {

  vec3 cam = getCam(uv);

  vec3 color = cam;

  float dif = length(uv - leftEye) * 10.;
  dif = min(dif, length(uv - rightEye) * 10.);
  dif = min(dif, 1.0);
  color = cam / vec3(dif);
  gl_FragColor = vec4(color, 1);
}

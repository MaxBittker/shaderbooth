void main() {

  vec3 cam = getCam(uv);
  float face = getFace(uv);
  vec3 color = cam;

  vec2 offset = pixel * 10.;
  vec3 blur = getCam(uv + vec2(offset.x, 0.)) / 4.;
  blur += getCam(uv + vec2(-offset.x, 0.)) / 4.;
  blur += getCam(uv + vec2(0., offset.y)) / 4.;
  blur += getCam(uv + vec2(0., -offset.y)) / 4.;

  float nChunks = 30.;
  vec2 chunkedPos = (floor(uv * nChunks) + 0.5) / nChunks;
  vec3 pixelate = getCam(chunkedPos);
  if (face > 0.2) {

    color = pixelate;
    // uncomment:
    // color = blur;
  }

  gl_FragColor = vec4(color, 1);
}

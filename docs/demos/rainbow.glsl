void main() {

  vec2 pos = uv;
  if (getFace(uv) < 0.5) {
    pos.x += sin(400. + pos.y * 90.) * 0.01;
    pos.y += sin(pos.x * 90.) * 0.01;
  }
  vec3 color = getCam(pos);
  float l = luma(color);
  vec3 hsl = rgb2hsl(color);
  float hue = (l + 50. + mod(time, 60.)) * 0.1;
  hue *= l * 1.;
  hue = mod(hue, 1.0);
  color = hsl2rgb(hue, 0.7, hsl.z);
  if (getFace(uv) > 0.5) {
    color = hsl2rgb(hue * 0.7 + 0.1, 0.7, hsl.z);
  }
  gl_FragColor = vec4(color, 1);
}
void main() {

  vec2 pos = uv;
  if (getFace(uv) < 0.5) {
    pos.x += sin(5. + pos.y * 90.) * 0.02;
    pos.y += sin(pos.x * 1290.) * 0.05;
  }
  vec3 color = getCam(pos);
  float l = luma(color);
  vec3 hsl = rgb2hsl(color);
  float hue = (l + mod(time, 30.) + 300.) * 0.1;
  hue *= l * 0.02;
  hue += faceCenter.x + faceCenter.y;

  hue = mod(hue, 1.0);
  color = hsl2rgb(hue, 0.7, hsl.z);
  color = hsl2rgb(hue * 1.2 + 0.1, 0.7, hsl.z);

  gl_FragColor = vec4(color, 1);
}

void main() {

  vec3 wcolor = getCam(uv).rgb;
  float wmag = luma(wcolor);
  wcolor = hsl2rgb((sin(time * 0.001) * 0.5) + 1.0, 0.2, wmag + 0.5);

  int n = 5;
  float uB = luma(getPrevious(uv + pixel * vec2(0., 2.0)).rgb);
  float dB = luma(getPrevious(uv + pixel * vec2(0, -2.0)).rgb);
  float lB = luma(getPrevious(uv + pixel * vec2(-2.0, 0.)).rgb);
  float rB = luma(getPrevious(uv + pixel * vec2(2.0, 0.)).rgb);

  vec2 d = vec2(rB - lB, dB - uB);

  vec3 scolor = getPrevious(uv + d * pixel * 10.).rgb;

  vec3 color = wcolor;

  if (luma(wcolor) > luma(scolor) /*webcam darker*/
      && luma(wcolor) * 0.7 + sin(time * 1.) * 0.1 < luma(scolor)) {
    color = scolor;
  }
  if (getFace(uv) < 0.4) {
    color += vec3(0.001);
  }
  gl_FragColor.rgb = color;

  gl_FragColor.a = 1.0;
}
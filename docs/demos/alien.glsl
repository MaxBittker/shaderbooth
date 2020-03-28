void main() {

  vec2 pos = uv;
  vec3 color = getCam(uv);
  //     color = getPrevious(pos+pixel*30.);

  for (int i = 0; i < 10; i++) {
    float scale = 1.0 - float(i) * 0.02; // * abs(sin(time));
    vec2 offset = vec2(0.2, 0.01) * float(i) * 0.0001;
    float wiggleAngle = noise(vec3(uv, float(i) + time * 0.2) * 0.334) * TAU;

    offset += vec2(sin(wiggleAngle), cos(wiggleAngle)) * 0.1;
    vec2 epos = (pos * scale) + offset;

    if (getMouth(epos) > 0.5 && getMouth(epos) < 1.5) {
      color = getCam(epos);
    }
    if (getEye(epos) > 0.6) {
      color = getCam(epos);
    }
  }

  gl_FragColor = vec4(color, 1);
}

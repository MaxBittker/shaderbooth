void main() {

  vec3 color = getCam(uv);

  vec2 pos = uv;

  pos -= faceCenter;
  pos /= 2.0;
  pos += faceCenter;
  pos.y -= 0.1;

  if (getMouth(pos) > 0.3) {
    color = getCam(pos);
  }

  pos.y += 0.2;
  pos.x *= 1.5;
  if (getEye(pos) > 0.6) {
    // big eyes:
    //     color = getCam(pos);
  }

  gl_FragColor = vec4(color, 1);
}

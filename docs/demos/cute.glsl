void main() {

  vec3 color = getCam(uv);

  vec2 offset = pixel * 1.5;
  vec3 blur = getCam(uv + vec2(offset.x, 0.)) / 4.;
  blur += getCam(uv + vec2(-offset.x, 0.)) / 4.;
  blur += getCam(uv + vec2(0., offset.y)) / 4.;
  blur += getCam(uv + vec2(0., -offset.y)) / 4.;

  float freckles = clamp(noise(uv * 100.) - 0.6, 0., 1.0);
  float frecklePattern = min(length(uv - faceCenter + vec2(0.2, 0.)),
                             length(uv - faceCenter - vec2(0.2, 0.)));
  frecklePattern = .15 - frecklePattern;
  frecklePattern = clamp(frecklePattern, 0., 0.5);
  freckles *= frecklePattern;
  vec2 pos = uv;

  if (getFace(uv) > 0.2) {
    color = blur;
    color -= freckles * vec3(1.0) * 7.;
    // blush:
    color += frecklePattern * red * 1.5;
  }

  // lashes and pupils darker
  if (getEye(uv) > 0.3) {
    color = getCam(uv);
    if (luma(color) < 0.3) {
      color /= 2.;
    }
  }
  // eyes brighter
  if (getEye(uv) > 0.8) {
    if (luma(color) > 0.5) {
      color *= 1.4;
    }
  }
  if (getMouth(uv) > 0.2 && getMouth(uv) < 0.7) {
    color = getCam(uv);
    // lipgloss
    //     color*=color;
    //     color+=0.2;
    //     color *= vec3(0.98,0.9,1.0);
  }

  gl_FragColor = vec4(color, 1);
}

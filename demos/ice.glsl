void main() {

  vec3 cam = getCam(uv);

  vec2 offset = vec2(noise(vec3(uv * 5., time * 0.1)),
                     noise(vec3(uv * 5. + vec2(0.3), time * 0.1))) *
                pixel * 3.;
  offset += vec2(0., -pixel.y * 2.);
  offset *= rand(uv.x + uv.y + time);
  vec3 prev = getPrevious(uv + offset);

  float face = getFace(uv);
  float eye = getEye(uv);
  float mouth = getMouth(uv);

  vec2 ed = 6. * pixel;
  float edge = dot((getCam(uv) * 4. - getCam(uv + vec2(ed.x, 0)) -
                    getCam(uv + vec2(-ed.x, 0)) - getCam(uv + vec2(0., ed.y)) -
                    getCam(uv + vec2(0, -ed.y)))
                       .rgb,
                   vec3(0.333));

  cam = vec3(0.7, .8, 1.0) * dot(cam, vec3(0.333));

  vec3 color = cam;

  color = (edge + 0.1) * cam * 30.;

  if (eye < 0.8 && mouth < 0.2) {
    color = prev * 0.95 + edge * 0.5 + cam * 0.05;
  }

  if (face > 0.3) {
    color = mix(color, cam, 0.5);
  }

  gl_FragColor = vec4(color, 1);
}

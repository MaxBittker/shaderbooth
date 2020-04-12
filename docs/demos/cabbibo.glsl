
vec2 modit(vec2 x, vec2 y) { return x - y * floor(x / y); }

float modit(float x, float y) { return x - y * floor(x / y); }
void main() {

  vec2 pos = vec2(uv.x, uv.y * resolution.y / resolution.x) * 1.3;
  vec3 color = getCam(pos);
  vec3 camCol = color;

  float hit = 0.;

  vec3 ro = vec3(pos.x, pos.y, 1.);
  vec3 rd = normalize(ro - vec3(0.));

  vec3 faceVec = vec3(faceCenter.x, faceCenter.y + .1, 1.3);

  int hitStep = 0;
  color = vec3(1.);
  for (int i = 0; i < 20; i++) {
    vec3 pos2 = ro + rd * float(i) * .04;

    float fV = length(faceVec - pos2);

    hit = fV * .5 + fbn((pos2 * 4. + vec3(0., 0., time * .3)), 3) * .1 * fV *
                        fV * fV * 20.;

    if (i == 17) {
      if (getFace(pos2.xy * .7) > .5) {
        hitStep = i;
        color = getCam(pos2.xy * .7);
        vec3(1., 0., 0.);
        break;
      }
    }
    if (hit > .34) {
      color = hsl2rgb(modit((float(i) / 100.) + hit * .01 +
                                sin(float(i) * 0.1) * .2 + time * .1,
                            1.),
                      .4, 0.4 + float(i) / 40.);
      hitStep = i;

      break;
    }
  }

  if (hitStep == 0) {
    color = getPrevious(uv) * .9;
  }

  gl_FragColor = vec4(color, 1);
}

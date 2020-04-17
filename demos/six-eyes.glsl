void main() {

  vec3 cam = getCam(uv);
  vec3 color = cam;

  vec2 eveVector = leftEye - rightEye;
  float occularDistance = length(eveVector);

  vec2 offset = vec2(occularDistance * 0.5);

  eveVector = normalize(eveVector);
  eveVector = vec2(-eveVector.y, eveVector.x);

  offset *= eveVector;

  if (getEye(uv - offset) > 0.6) {
    color = getPrevious(uv - offset * 2.);
  }

  offset *= -1.0;

  if (getEye(uv - offset) > 0.6) {
    color = getPrevious(uv - offset);
  }

  gl_FragColor = vec4(color, 1);
}

void main() {

  float distanceFromCenter = length(uv - faceCenter);
  distanceFromCenter = clamp(distanceFromCenter, 0.0, 0.5);

  float howMuchToRotate = map(distanceFromCenter, 0.0, 0.5, 1.0, 0.0);
  howMuchToRotate = pow(howMuchToRotate, 3.) * 0.5;

  vec2 position = rotate(uv, howMuchToRotate);
  position *= 1.0 + howMuchToRotate * 2.;

  vec3 color = getCam(position);

  gl_FragColor = vec4(color, 1);
}

// Demo of some face feature  stuff;
// leftEye, rightEye, faceCenter.

float sdCapsule(vec2 p, vec2 a, vec2 b, float r) {
  vec2 pa = p - a, ba = b - a;
  float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
  return length(pa - ba * h) - r;
}

float sdCircle(vec2 p, float r) { return length(p) - r; }
void main() {

  vec3 cam = getCam(uv);
  vec3 color = cam;

  vec2 eyeVector = leftEye - rightEye;
  float occularDistance = length(eyeVector);

  vec2 offset = vec2(occularDistance * 0.5);

  eyeVector = normalize(eyeVector);
  vec2 eyeVectorPerp = vec2(-eyeVector.y, eyeVector.x);

  offset *= eyeVector;

  float line = sdCapsule(uv, leftEye, rightEye, 0.03);
  if (line < 0.0) {
    color = vec3(rand(time + uv.x));
  }

  //   line = sdCapsule(uv - (leftEye + rightEye) * 0.5,
  //                    eyeVectorPerp * occularDistance,
  //                    eyeVectorPerp * -occularDistance, 0.005);
  //   if (line < 0.0) {
  //     color *= green;
  //   }

  //   if (sdCircle(faceCenter - uv, 0.06) < 0.00) {
  //     color *= red;
  //   }

  gl_FragColor = vec4(color, 1);
}

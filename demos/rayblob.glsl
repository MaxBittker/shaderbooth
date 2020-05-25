
// diffuse is the softer part of the light
float orenNayarDiffuse(vec3 lightDirection, vec3 viewDirection,
                       vec3 surfaceNormal, float roughness, float albedo) {

  float LdotV = dot(lightDirection, viewDirection);
  float NdotL = dot(lightDirection, surfaceNormal);
  float NdotV = dot(surfaceNormal, viewDirection);

  float s = LdotV - NdotL * NdotV;
  float t = mix(1.0, max(NdotL, NdotV), step(0.0, s));

  float sigma2 = roughness * roughness;
  float A = 1.0 + sigma2 * (albedo / (sigma2 + 0.13) + 0.5 / (sigma2 + 0.33));
  float B = 0.45 * sigma2 / (sigma2 + 0.09);

  return albedo * max(0.0, NdotL) * (A + B * s / t) / PI;
}

// specular means the shiny parts
float gaussianSpecular(vec3 lightDirection, vec3 viewDirection,
                       vec3 surfaceNormal, float shininess) {
  vec3 H = normalize(lightDirection + viewDirection);
  float theta = acos(dot(H, surfaceNormal));
  float w = theta / shininess;
  return exp(-w * w);
}

// Define some constants
const int steps = 128; // This is the maximum amount a ray can march.
const float smallNumber = 0.001;
const float maxDist = 10.; // This is the maximum distance a ray can travel.

float scene(vec3 position) {
  // So this is different from the normal sphere equation in that I am
  // splitting the position into it's three different parts
  // and adding a 10th of a cos wave to the x position so it oscillates left
  // to right and a (positive) sin wave to the z position
  // so it will go back and forth.

  float radius = 1.9;

  vec2 eyeVector = leftEye - rightEye;
  float occularDistance = length(eyeVector);

  radius += noise(position * 1.7) * 0.58;
  radius *= occularDistance;

  float sphere = length(vec3(position.x + cos(time) / 20., position.y,
                             position.z + (sin(time) + 10.) / 15.)) -
                 radius;

  // This is different from the ground equation because the UV is only
  // between -1 and 1 we want more than 1/2pi of a wave per length of the
  // screen so we multiply the position by a factor of 10 inside the trig
  // functions. Since sin and cos oscillate between -1 and 1, that would be
  // the entire height of the screen so we divide by a factor of 10.
  float ground = position.y + sin(position.x * 10.) / 10. +
                 cos(position.z * 10.) / 10. + 1.;

  // We want to return whichever one is closest to the ray, so we return the
  // minimum distance.
  return sphere;
  min(sphere, ground);
}

vec3 estimateNormal(vec3 p) {
  vec3 n = vec3(scene(vec3(p.x + smallNumber, p.yz)) -
                    scene(vec3(p.x - smallNumber, p.yz)),
                scene(vec3(p.x, p.y + smallNumber, p.z)) -
                    scene(vec3(p.x, p.y - smallNumber, p.z)),
                scene(vec3(p.xy, p.z + smallNumber)) -
                    scene(vec3(p.xy, p.z - smallNumber)));
  // poke around the point to get the line perpandicular
  // to the surface at p, a point in space.
  return normalize(n);
}

vec4 lighting(vec3 pos, vec3 rd) {

  vec3 normal = estimateNormal(pos);

  // red light
  vec3 direction1 = normalize(vec3(-.9, 1, 0));
  vec3 color1 = vec3(0.5, 1.3, 1.3);
  vec3 dif1 = color1 * orenNayarDiffuse(direction1, -rd, normal, 0.15, 1.0);
  vec3 spc1 = color1 * gaussianSpecular(direction1, -rd, normal, 0.15);

  // blue light
  vec3 direction2 = normalize(vec3(0.4, 0.5, -0.4));
  vec3 color2 = vec3(1.3, 1.3, 0.9);
  vec3 dif2 = color2 * orenNayarDiffuse(direction2, -rd, normal, 0.15, 1.0);
  vec3 spc2 = color2 * gaussianSpecular(direction2, -rd, normal, 0.15);
  vec3 color = dif1 + spc1 + dif2 + spc2;
  color *= 0.5;
  color += white * 0.5;
  color *= getCam(normal.xy * 0.8);
  // color = getCam(normal.xy );
  return vec4(color, 1.0);
}

vec4 trace(vec3 origin, vec3 direction) {

  float dist = 0.;
  float totalDistance = 0.;
  vec3 positionOnRay = origin;

  for (int i = 0; i < steps; i++) {

    dist = scene(positionOnRay);

    // Advance along the ray trajectory the amount that we know the ray
    // can travel without going through an object.
    positionOnRay += dist * direction;

    // Total distance is keeping track of how much the ray has traveled
    // thus far.
    totalDistance += dist;

    // If we hit an object or are close enough to an object,
    if (dist < smallNumber) {
      // return the lighting
      return lighting(positionOnRay, direction);
    }

    if (totalDistance > maxDist) {

      return vec4(black, 1.); // Background color.
    }
  }
  return vec4(black, 1.); // Background color.
}

vec3 lookAt(vec2 uv, vec3 camOrigin, vec3 camTarget) {
  // we get the z Axis the same way we got the direction vector before
  vec3 zAxis = normalize(camTarget - camOrigin);
  vec3 up = vec3(0, 1, 0);
  // cross product of two vectors produces a third vector that is
  // orthogonal to the first two (if you were to make a plane
  // with the first two vectors the third is perpendicular to that
  // plane. Which direction is determined by the 'right hand rule'
  // It is not communicative, so the order here matters.
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = normalize(cross(zAxis, xAxis));
  // normalizing makes the vector of length one by dividing the
  // vector by the sum of squares (the norm).

  float fov = 2.;
  // scale each unit vector (aka vector of length one) by the ray origin
  // one for x one for y, there is no z vector so we just add it
  // then we finally scale by FOV
  vec3 dir = (normalize((uv.x * xAxis) + (uv.y * yAxis) + (zAxis * fov)));

  return dir;
}

void main() {

  vec2 pos = uv;
  pos.x *= resolution.x / resolution.y;

  vec3 camOrigin = vec3(0, 0, -4.0);
  // vec3 rayOrigin = vec3(pos + camOrigin.xy, camOrigin.z + 1.);
  vec3 target = vec3(-faceCenter, 0);
  vec3 dir = lookAt(pos, camOrigin, target);
  vec4 color = vec4(trace(camOrigin, dir));
  if (length(color.rgb) < 0.1) {
    color.rgb = getCam(uv);
    //       color.r = 1.
  } else {
    color.rgb += getCam(uv) * 0.1;
  }
  gl_FragColor = color;
}
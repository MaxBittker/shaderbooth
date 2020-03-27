// Ricky Reusser @rreusser
// https://github.com/Erkaman/glsl-godrays/blob/master/example/index.js
vec3 godrays(float density, float weight, float decay, float exposure,
             int numSamples, sampler2D occlusionTexture,
             vec2 screenSpaceLightPos, vec2 uv) {
  vec3 fragColor = vec3(0.0, 0.0, 0.0);
  vec2 deltaTextCoord = vec2(uv - screenSpaceLightPos.xy);
  vec2 textCoo = uv.xy;
  deltaTextCoord *= (1.0 / float(numSamples)) * density;
  float illuminationDecay = 1.0;
  for (int i = 0; i < 200; i++) {
    if (numSamples < i)
      break;
    textCoo -= deltaTextCoord;
    vec3 samp = texture2D(occlusionTexture, textCoo).xyz;
    samp.xy -= vec2(0.5, 0.2);
    samp.xy = max(samp.xy, 0.);
    samp.xy * -4.;

    samp = vec3(dot(samp.xy, samp.xy));
    samp *= illuminationDecay * weight;
    fragColor += samp;
    illuminationDecay *= decay;
  }
  fragColor *= vec3(1.0, 0.7, 0.5);
  fragColor *= exposure;
  return fragColor;
}

void main() {
  vec3 cam = getCam(uv);
  vec3 color = cam * 0.5;
  color += godrays(1.0, 0.01, 1.0, 4.0, 200, maskTex, vec2(0.5, 0.55),
                   0.5 - 0.5 * uv);
  gl_FragColor = vec4(color, 1);
}
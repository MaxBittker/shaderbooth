precision mediump float;
uniform float tick;
uniform float time;
uniform float targetAspect;
uniform bool hasFace;
uniform vec2 resolution;
uniform sampler2D previousTex;
uniform sampler2D camTex;
uniform vec2 videoResolution;
uniform vec2 scaledVideoResolution;
varying vec2 uv;

vec2 pixel = 1.0 / resolution;

vec3 getCam(vec2 pos) {
  float videoAspect = videoResolution.x / videoResolution.y;

  vec2 uvAspect = vec2(pos.x * targetAspect / videoAspect, pos.y);
  if ((targetAspect) < (videoResolution.x / videoResolution.y)) {
    uvAspect = vec2(pos.x, pos.y * videoAspect / targetAspect);
  }
  vec2 webcamCoord = (uvAspect) / 2.0 + vec2(0.5);
  vec2 flipwcord = vec2(1.) - webcamCoord;

  float howFar = 1.0;
  if (uvAspect.x <= -1.0 || uvAspect.x > 1.0 || uvAspect.y < -1.0 ||
      uvAspect.y > 1.0) {
    howFar = max(abs(uvAspect.x), abs(uvAspect.y)) - 1.0;
    howFar = 2.0 + float(int(howFar * 5.));
    vec2 towardsCenter = vec2(0., 0.0);
    if (uvAspect.x < -1.) {
      towardsCenter = vec2(-1.0, 0.0);
    } else if (uvAspect.x > 1.) {
      towardsCenter = vec2(1.0, 0.0);
    } else if (uvAspect.y > 1.) {
      towardsCenter = vec2(0.0, 1.0);
    } else if (uvAspect.y < -1.) {
      towardsCenter = vec2(0.0, -1.0);
    }
    flipwcord += towardsCenter * (1. / 8.) * howFar;
    float blurRadius = 4.0 + howFar;

    float blurAngle = sin((flipwcord.x + flipwcord.y) * 555.534) * 3.14 * 2.;
    vec2 blurOffset = vec2(cos(blurAngle), sin(blurAngle)) * pixel * blurRadius;
    vec3 color = texture2D(camTex, flipwcord + blurOffset).rgb / 3.;

    blurAngle += 2.0;
    blurOffset = vec2(cos(blurAngle), sin(blurAngle)) * pixel * blurRadius;
    color += texture2D(camTex, flipwcord + blurOffset).rgb / 3.;

    blurAngle += 2.0;
    blurOffset = vec2(cos(blurAngle), sin(blurAngle)) * pixel * blurRadius;
    color += texture2D(camTex, flipwcord + blurOffset).rgb / 3.;

    return color;
  }

  return texture2D(camTex, flipwcord).rgb;
}

void main() {
  vec2 uvN = (uv * 0.5) + vec2(0.5);

  vec2 backCoord = uv * (1.0 + 0.01);
  backCoord = (backCoord / 2.0) + vec2(0.5);
  vec3 backBufferColor = texture2D(previousTex, backCoord).rgb;
  vec3 color = getCam(uv);

  if (!hasFace) {
    float scanLine = mod(time * 0.5, 1.0);
    if (abs(uvN.x - scanLine) < pixel.x * 1.) {
      color += vec3(0., 1.0, 0.) *
               (0.5 + max(sin(uvN.y * 200. + time * 2.0), 0.0) * 0.5);
    }
    color.g = color.g * 0.5 + backBufferColor.g * 0.5;
  }
  gl_FragColor = vec4(color, 1);
}

precision mediump float;

varying vec2 uv;
uniform float time;
uniform vec2 resolution;
uniform vec2 videoResolution;
uniform vec2 scaledVideoResolution;
uniform sampler2D camTex;
uniform sampler2D maskTex;
uniform sampler2D previousTex;
// SPACER

vec2 pixel = 1.0 / resolution;

// SPACER

vec3 getCam(vec2 pos) {
  vec2 resRatio = scaledVideoResolution / resolution;
  vec2 webcamCoord = (pos / resRatio) / 2.0 + vec2(0.5);
  vec2 flipwcord = vec2(1.) - webcamCoord;
  return texture2D(camTex, flipwcord).rgb;
}

vec3 getPrevious(vec2 pos) {
  vec2 backCoord = (pos / 2.0) + vec2(0.5);
  return texture2D(previousTex, backCoord).rgb;
}
// SPACER

// Access Facial Feature Masks

float getFace(vec2 pos) {
  vec2 resRatio = scaledVideoResolution / resolution;
  vec2 webcamCoord = (pos / resRatio) / 2.0 + vec2(0.5);
  vec2 flipwcord = vec2(1.) - webcamCoord;
  return texture2D(maskTex, flipwcord).b;
}
float getEye(vec2 pos) {
  vec2 resRatio = scaledVideoResolution / resolution;
  vec2 webcamCoord = (pos / resRatio) / 2.0 + vec2(0.5);
  vec2 flipwcord = vec2(1.) - webcamCoord;
  return texture2D(maskTex, flipwcord).g;
}
float getMouth(vec2 pos) {
  vec2 resRatio = scaledVideoResolution / resolution;
  vec2 webcamCoord = (pos / resRatio) / 2.0 + vec2(0.5);
  vec2 flipwcord = vec2(1.) - webcamCoord;
  return texture2D(maskTex, flipwcord).r;
}

// SPACER
vec2 rotate(vec2 v, float a) {
  float s = sin(a);
  float c = cos(a);
  mat2 m = mat2(c, -s, s, c);
  return m * v;
}

// SPACER
// Color Shorthands

vec3 black = vec3(0.0);
vec3 white = vec3(1.0);
vec3 red = vec3(0.86, 0.22, 0.27);
vec3 orange = vec3(0.92, 0.49, 0.07);
vec3 yellow = vec3(0.91, 0.89, 0.26);
vec3 green = vec3(0.0, 0.71, 0.31);
vec3 blue = vec3(0.05, 0.35, 0.65);
vec3 purple = vec3(0.38, 0.09, 0.64);
vec3 pink = vec3(.9, 0.758, 0.798);
vec3 lime = vec3(0.361, 0.969, 0.282);
vec3 teal = vec3(0.396, 0.878, 0.878);
vec3 magenta = vec3(1.0, 0.189, 0.745);
vec3 brown = vec3(0.96, 0.474, 0.227);
// SPACER
float rand(float n) { return fract(sin(n) * 43758.5453123); }

// 1D, 2D, 3D Simplex Noise
float noise(float p) {
  float fl = floor(p);
  float fc = fract(p);
  return mix(rand(fl), rand(fl + 1.0), fc);
}

// INTERNAL
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
// INTERNAL
vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
// INTERNAL
vec3 permute(vec3 x) { return mod289(((x * 34.0) + 1.0) * x); }

float noise(vec2 v) {
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                      -0.577350269189626, // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
                                          // First corner
  vec2 i = floor(v + dot(v, C.yy));
  vec2 x0 = v - i + dot(i, C.xx);

  // Other corners
  vec2 i1;
  // i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  // i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

  // Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p =
      permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));

  vec3 m = max(
      0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
  m = m * m;
  m = m * m;

  // Gradients: 41 points uniformly over a line, mapped onto a diamond.
  // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

  // Normalise gradients implicitly by scaling m
  // Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);

  // Compute final noise value at P
  vec3 g;
  g.x = a0.x * x0.x + h.x * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

// INTERNAL
vec3 mod289_3(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
// INTERNAL
vec4 mod289_4(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
// INTERNAL
vec4 permute(vec4 x) { return mod289_4(((x * 34.0) + 1.0) * x); }
// INTERNAL
vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }

float noise(vec3 v) {
  const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);
  const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);

  // First corner
  vec3 i = floor(v + dot(v, C.yyy));
  vec3 x0 = v - i + dot(i, C.xxx);

  // Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min(g.xyz, l.zxy);
  vec3 i2 = max(g.xyz, l.zxy);

  //   x0 = x0 - 0.0 + 0.0 * C.xxx;
  //   x1 = x0 - i1  + 1.0 * C.xxx;
  //   x2 = x0 - i2  + 2.0 * C.xxx;
  //   x3 = x0 - 1.0 + 3.0 * C.xxx;
  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
  vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

  // Permutations
  i = mod289_3(i);
  vec4 p = permute(permute(permute(i.z + vec4(0.0, i1.z, i2.z, 1.0)) + i.y +
                           vec4(0.0, i1.y, i2.y, 1.0)) +
                   i.x + vec4(0.0, i1.x, i2.x, 1.0));

  // Gradients: 7x7 points over a square, mapped onto an octahedron.
  // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
  float n_ = 0.142857142857; // 1.0/7.0
  vec3 ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z * ns.z); //  mod(p,7*7)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_); // mod(j,N)

  vec4 x = x_ * ns.x + ns.yyyy;
  vec4 y = y_ * ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4(x.xy, y.xy);
  vec4 b1 = vec4(x.zw, y.zw);

  // vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
  // vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
  vec4 s0 = floor(b0) * 2.0 + 1.0;
  vec4 s1 = floor(b1) * 2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
  vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

  vec3 p0 = vec3(a0.xy, h.x);
  vec3 p1 = vec3(a0.zw, h.y);
  vec3 p2 = vec3(a1.xy, h.z);
  vec3 p3 = vec3(a1.zw, h.w);

  // Normalise gradients
  vec4 norm =
      taylorInvSqrt(vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

  // Mix final noise value
  vec4 m =
      max(0.6 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
  m = m * m;
  return 42.0 *
         dot(m * m, vec4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
}

// Fractal Brownian Noise
float fbn(float x, const in int iterations) {
  float v = 0.0;
  float a = 0.5;
  float shift = float(100);
  for (int i = 0; i < 32; ++i) {
    if (i < iterations) {
      v += a * noise(x);
      x = x * 2.0 + shift;
      a *= 0.5;
    }
  }
  return v;
}

float fbn(vec2 x, const in int iterations) {
  float v = 0.0;
  float a = 0.5;
  vec2 shift = vec2(100);
  // Rotate to reduce axial bias
  mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
  for (int i = 0; i < 32; ++i) {
    if (i < iterations) {
      v += a * noise(x);
      x = rot * x * 2.0 + shift;
      a *= 0.5;
    }
  }
  return v;
}

float fbn(vec3 x, const in int iterations) {
  float v = 0.0;
  float a = 0.5;
  vec3 shift = vec3(100);
  for (int i = 0; i < 32; ++i) {
    if (i < iterations) {
      v += a * noise(x);
      x = x * 2.0 + shift;
      a *= 0.5;
    }
  }
  return v;
}
// SPACER
// INTERNAL
float hue2rgb(float f1, float f2, float hue) {
  // http://www.chilliant.com/rgb2hsv.html

  if (hue < 0.0)
    hue += 1.0;
  else if (hue > 1.0)
    hue -= 1.0;
  float res;
  if ((6.0 * hue) < 1.0)
    res = f1 + (f2 - f1) * 6.0 * hue;
  else if ((2.0 * hue) < 1.0)
    res = f2;
  else if ((3.0 * hue) < 2.0)
    res = f1 + (f2 - f1) * ((2.0 / 3.0) - hue) * 6.0;
  else
    res = f1;
  return res;
}

// Color Space Conversion

vec3 hsl2rgb(vec3 hsl) {
  vec3 rgb;

  if (hsl.y == 0.0) {
    rgb = vec3(hsl.z); // Luminance
  } else {
    float f2;

    if (hsl.z < 0.5)
      f2 = hsl.z * (1.0 + hsl.y);
    else
      f2 = hsl.z + hsl.y - hsl.y * hsl.z;

    float f1 = 2.0 * hsl.z - f2;

    rgb.r = hue2rgb(f1, f2, hsl.x + (1.0 / 3.0));
    rgb.g = hue2rgb(f1, f2, hsl.x);
    rgb.b = hue2rgb(f1, f2, hsl.x - (1.0 / 3.0));
  }
  return rgb;
}

vec3 hsl2rgb(float h, float s, float l) { return hsl2rgb(vec3(h, s, l)); }

// INTERNAL
vec3 RGBtoHCV(vec3 rgb) {
  // Based on work by Sam Hocevar and Emil Persson
  vec4 p = (rgb.g < rgb.b) ? vec4(rgb.bg, -1.0, 2.0 / 3.0)
                           : vec4(rgb.gb, 0.0, -1.0 / 3.0);
  vec4 q = (rgb.r < p.x) ? vec4(p.xyw, rgb.r) : vec4(rgb.r, p.yzx);
  float c = q.x - min(q.w, q.y);
  float h = abs((q.w - q.y) / (6.0 * c + 1e-10) + q.z);
  return vec3(h, c, q.x);
}

vec3 rgb2hsl(vec3 rgb) {
  vec3 hcv = RGBtoHCV(rgb);
  float l = hcv.z - hcv.y * 0.5;
  float s = hcv.y / (1.0 - abs(l * 2.0 - 1.0) + 1e-10);
  return vec3(hcv.x, s, l);
}

vec3 rgb2hsl(float r, float g, float b) { return rgb2hsl(vec3(r, g, b)); }

float luma(vec3 color) { return dot(color, vec3(0.299, 0.587, 0.114)); }

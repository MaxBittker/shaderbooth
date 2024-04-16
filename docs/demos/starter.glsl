// Welcome to Shaderbooth!
//    ______           __        ___            __  __
//   / __/ /  ___ ____/ /__ ____/ _ )___  ___  / /_/ /
//  _\ \/ _ \/ _ `/ _  / -_) __/ _  / _ \/ _ \/ __/ _ \
// /___/_//_/\_,_/\_,_/\__/_/ /____/\___/\___/\__/_//_/
//

// This is an interactive editor for making face filters with WebGL.
// The language below is called GLSL, you can edit it to change the effect.
// Press the arrows in the bottom right to see more examples!

void main() {

  vec3 cam = getCam(uv);
  vec3 prev = getPrevious(uv * 1.05 + pixel * 20.);

  float face = getFace(uv);
  float eye = getEye(uv);
  float mouth = getMouth(uv);

  vec3 color = cam;

  // try uncommenting this line:
  // color = getPrevious(uv + (cam.rg-cam.bb)*0.1);

  vec2 offset = uv - faceCenter;
  if (face > 0.2) {
    color = cam * pink;
    color.g += .1*sin((offset.y +offset.x)*100.) ;
    // or this one
   // color = getPrevious(rotate(uv, 0.1) * 1.1);
  }

  // eye black
  if (eye > 0.3) {
    color += green*.3;
  }
  if (eye > 0.6) {
    color = cam;
  }
  // lipstick
  if (mouth > 0.4) {
      color += green*.3;
  }
  if (mouth > 0.6 ) {
    color = cam;
  }
  if (max(abs(uv.x), abs(uv.y)) > 0.99) {
    color = cam;
  }
  gl_FragColor = vec4(color, 1);
}

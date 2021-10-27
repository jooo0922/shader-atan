#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

vec3 rgb2hsb(in vec3 c) {
  vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
  vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
  vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
  float d = q.x - min(q.w, q.y);
  float e = 1.0e-10;
  return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

//  Function from Iñigo Quiles
//  https://www.shadertoy.com/view/MsS3Wc
vec3 hsb2rgb(in vec3 c) {
  vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
  rgb = rgb * rgb * (3.0 - 2.0 * rgb);
  return c.z * mix(vec3(1.0), rgb, c.y);
}

void main() {
  vec2 st = gl_FragCoord.xy / u_resolution; // 각 픽셀들의 좌표값 normalize
  vec3 color = vec3(0.0); // 초기값을 black으로 한 vec3 변수 만들어놓음.

    // We map x (0.0 - 1.0) to the hue (0.0 - 1.0)
    // And the y (0.0 - 1.0) to the brightness
  color = hsb2rgb(vec3(st.x, 1.0, st.y));

  gl_FragColor = vec4(color, 1.0);
}

/*
  사용자 정의 함수
  hsb2rgb() vs rgb2hsb() 에 대한 설명


  이름에서도 유추할 수 있겠지만,

  hsb2rgb(vec3(c, c, c)) 는
  hsb 컬러값을 인자로 전달해주면 rgb 컬러값으로 변환하여 리턴해주는 함수일 것이고,

  rgb2hsb(vec3(c, c, c)) 는
  rgb 컬러값을 인자로 전달해주면 hsb(hsl) 컬러값으로 변환하여 리턴해주는 함수겠지.

  그래서 main 함수에서는 hsb2rgb에 vec3 값을 넘겨주면서 함수를 호출하고 있음.
  이 때, 당연히 st.x는 hsb에서 hue값이 될 것이고,
  st.y는 hsb에서 brightness(명도)가 될 것이고,
  가운데 1.0은 saturation(채도)가 되겠지.

  -> 따라서, 0 ~ 1 사이의 정규화된 x좌표값이 오른쪽으로 갈수록 증가됨에 따라 
  빨주노초파람보 ~ 빨 이라는 hue의 주기가 보이게 되지?
  또한, brightness도 각 픽셀들의 정규화된 y값이 커짐에 따라 증가하기 때문에,
  glsl에서 캔버스 뷰포트는 좌하단이 원점이므로, 
  뷰포트 아래로 갈수록 st.y값이 0에 가까워서 어두운 색상이 찍히고,
  뷰포트 위로 갈수록 st.y값이 1에 가까워서 밝은 색상이 찍히고 있지!

  참고로, hsb 는 hsl(색상, 채도, 명도)과 동일하다고 보면 됨.

  이때, 내부 함수의 소스코드를 굳이 분석하면서 공부할 필요는 없음.
  왜냐면, 이거 캔버스 프로젝트에서 사용했던 함수랑 비슷한 기능을 하는 것이기 때문에,
  이거를 굳이 이해할 게 아니라, '필요할 때 가져다 쓸 줄만 알면 된다' 정도의 마인드로 대하면 됨.

  캔버스 프로젝트에서도 그렇게 했으니까!
  이것도 gain() 함수를 만든 Iñigo Quiles 가 만든 함수들이라고 함.


  일단 첫번째 커밋의 코드들은
  그냥 두 번째 커밋에서 hsb2rgb() 함수를 사용하기 전에
  해당 함수를 간단히 소개하는 용도로 작성된 것 정도로 알고 있으면 됨. 
*/
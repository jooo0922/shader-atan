#ifdef GL_ES
precision mediump float;
#endif

#define TWO_PI 6.28318530718 // 360도를 라디안으로 표현한 상수값을 미리 정의해놓음.
#define PI 3.141592 // angle 계산 시 x축 왼쪽에서 PI / -PI 로 분절되는 각도값을 정리하기 위한 계산에 사용할 값

uniform vec2 u_resolution;
uniform float u_time;

//  Function from Iñigo Quiles
//  https://www.shadertoy.com/view/MsS3Wc
vec3 hsb2rgb(in vec3 c) {
  vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
  rgb = rgb * rgb * (3.0 - 2.0 * rgb);
  return c.z * mix(vec3(1.0), rgb, c.y);
}

// main() 함수 직접 짜기
void main() {
  vec2 coord = gl_FragCoord.xy / u_resolution; // 각 픽셀들의 좌표값 normalize

  // 이건 뭐냐면, 각 픽셀들의 정규화된 좌표값에다 각각 2.0을 곱하고, 1.0을 빼준 것.
  // 이렇게 하면, glsl 캔버스의 원점이 좌하단 -> 캔버스 가운데로 이동함.
  // 실제로, glsl 캔버스의 정규화된 가운데 좌표값 (0.5, 0.5) * 2.0 - 1.0 이거를 계산해주면
  // (0, 0)이 나옴. 즉, 원점을 좌하단 -> 가운데로 옮긴 것임.
  // 왜 이렇게 했느냐? 현재 예제가 캔버스의 가운데를 중심으로 atan 각도 계산, radius 계산이 되고 있으므로,
  // 원본 코드처럼 (0.5, 0.5)를 그대로 사용하는 게 아니라, 
  // 아예 가운데 좌표값을 (0, 0) 원점으로 바꿔준 뒤 계산을 하려는 것!
  coord = coord * 2. - 1.;

  float angle = atan(coord.y, coord.x);
  angle += PI; // 이렇게 해주면, 반시계방향 기준 180도(PI)와 시계방향 -180도(-PI)가 만나는 지점을 
  // 반시계방향 360도(2PI), 시계방향 0도(0)으로 뭔가 0도 ~ 360도 한바퀴 돌면 자연스럽게 다음 바퀴로 넘어가는 듯하게 정리해준 것.
  // 지가 생각해도 별 의미없는 계산같다고 함. 굳이 이렇게 해줄 필요까지는 없을 것 같음.
  // 이렇게 하면 원본 코드에서의 color wheel을 반바퀴 돌리게 되는 것임.
  // angle += PI + sin(u_time) * 5.; // 이런 식으로 u_time의 sin값을 매 프레임마다 계산해주면 color wheel이 회전하게 할 수도 있음.

  // Iñigo Quiles가 hsb2rgb() 함수를 만들 때,
  // hue값을 한바퀴 다 돌면 0 ~ 1을 거친다고 가정하고 만들었기 때문에,
  // hue값의 한바퀴 주기는 0 ~ 2PI가 아니라, 0 ~ 1로 넣어줘야 함.
  // 따라서 위에서 구한 angle값의 한바퀴 주기인 0 ~ 2PI 를 0 ~ 1로 Mapping 시키기 위해 각 angle에 2PI씩 나눠준 것.
  angle /= 2. * PI;
  angle *= 5.; // hue값을 0 ~ 1로 매핑시킨걸 다시 곱해주면, color wheel의 주기가 1번 이상으로 늘어남.

  // 거리를 리턴해주는 내장함수는 distance(좌표값1, 좌표값2) vs length(좌표값1) 둘 다 가능함.
  // 그런데, length가 받는 인자가 더 적어서 계산이 빠르기 때문에 length를 쓸거임.
  // 두 내장함수의 차이가 뭐냐면, distance()는 두 개의 포인트의 좌표값을 지정해줘서 두 포인트간의 거리를 계산함.
  // 반면, length()는 하나의 포인트 좌표값만 지정해줘서 해당 포인트와 원점 사이의 거리를 계산함.
  // 우리는 지금 원점을 가운데로 옮겨놨으니, 우리는 그냥 length에 각 픽셀들의 Mapping된 좌표값만 넣어줘도
  // 알아서 가운데 원점과의 거리가 나오게 되겠지
  float dist = length(coord);

  vec3 color = hsb2rgb(vec3(angle, dist, 1.));

  gl_FragColor = vec4(color, 1.);
}

/*
원본코드의 main함수 내용 설명


void main() {
  vec2 st = gl_FragCoord.xy / u_resolution; // 각 픽셀들의 좌표값 normalize
  vec3 color = vec3(0.0); // 기본값을 black으로 지정한 color값

  // Use polar coordinates instead of cartesian
  // (정규화된 가운데 좌표값 - 각 픽셀들의 정규화된 좌표값) 으로 각 픽셀에서 가운데점을 향하는 벡터값을 구함  
  vec2 toCenter = vec2(0.5) - st; 

  // 해당 벡터가 양의 x축과 이루는 각도값(즉, 해당 벡터의 기울기값)을 atan() 내장함수로 구함.
  float angle = atan(toCenter.y, toCenter.x);

  // 해당 벡터의 길이값은 0 ~ 0.5를 살짝 넘는 수준(대각선 길이)이므로, 2배를 곱해서 범주를 대략 0 ~ 1.~~ 로 변환함. 
  float radius = length(toCenter) * 2.0; 

  // Map the angle (-PI to PI) to the Hue (from 0 to 1)
  // and the Saturation to the radius
  // 각 픽셀들의 기울기값(각도값)을 360도로 나눈 값에서 + 0.5 한 게 hue값이고, (따라서 각도에 따라 색상이 달라짐)
  // 각 픽셀들의 벡터 길이(radius)를 saturation값, (따라서 가운데점에서 가까울수록 길이가 짧으니 채도가 흐리고, 멀수록 기니까 채도가 선명함.)
  // 명도는 1.0으로 고정시켜서 hsb값을 인자로 전달하여 변환된 rgb값을 리턴받음.
  color = hsb2rgb(vec3((angle / TWO_PI) + 0.5, radius, 1.0));

  // 변환하여 리턴된 rgb 색상값을 할당함.
  gl_FragColor = vec4(color, 1.0);
}
*/

/*
  atan(float y, float x)


  이번 예제에서 가장 핵심적인 내용으로 다루는 내장함수
  이전에 캔버스 프로젝트에서 좌표의 각도를 구할 때 사용해봤었다!

  atan() 은 기본적으로 각도를 리턴해주는 함수임.
  기울기값(정확히는, 좌표계 상에서 한 point의 x, y 좌표값)을 인자로 넣어주면
  그 기울기에 해당하는 각도(정확히는, 해당 포인트 - 원점이 이루는 벡터와 양의 x축 사이의 각도)를 리턴함.

  함수 그래프의 기울기값을 y/x 로 계산하기 때문에
  y좌표값을 먼저 넣어주고, 두 번째로 x좌표값을 넣어줌. 

  atan_방향별_리턴값.png 또는 atan2 관련 북마크 해놓은 자료 찾아보면
  반시계방향 / 시계방향에 따라 atan이 리턴해주는 각도값이 얼마인지 알 수 있음.
*/

/*
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
*/

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
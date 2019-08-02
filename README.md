# GPS_Parsing
GPS and DGPS Positioning Algorithm Based on Least Squares Method 졸업논문 GPS Parsing Source

<p align="center">
<img src="https://user-images.githubusercontent.com/50317129/62347974-88d48000-b536-11e9-93d3-6b9e477d8e52.png" width="70%" height="70%" alt="GPS Google Mapping" title="GPS Google Mapping">
</p>

NovAtel GPS 수신기를 이용해 Protocol을 수집하고 이를 통해 수신기의 위치를 후처리 계산함  

여러 Protocol 중, #SATXYZ2A와 #RANGEA를 이용하여 Least Square방식으로 위치를 계산  
계산된 위치를 Graph로 표시하여 원점을 기준으로 계산된 위치를 표시함  
2D, 3D RMS로 오차값 표시  

---
### Info  

개발언어 : `MATLAB`  

MATLAB은 행렬을 기본구조로 사용하기 때문에 GPS의 시간별 데이터 처리가 용이하다. 배열을 선언하지 않아도 그 자체로 배열이기 때문

---
## Script 매커니즘  

NovAtel 수신기를 이용하여 일정 시간동안 데이터를 수집함  
관련기관들은 하루 정도 수집해야 의미가 있다고 했지만, 너무 귀찮다  
그 많은 장비를 밖에다가 하루종일 놔둘 수도 없는 노릇이고  

수신지역은 주로 방해물이 없는 옥상에서 진행  
예전에 뭣도 모르고 그냥 좀 널널한 평지에서 했는데, 그것도 MultiPath의 영향이 있었다  
그것 때문에 계산방식이 잘못된 줄 알고 삽질 추가  

데이터에 포함돼야할 주요 프로토콜은 아래와 같다  

#### 주요 Protocol  

+ #SATXYZ2A
각 위성의 PRN, Frequency별 **XYZ좌표 및 오차정보**가 담긴 ASCII Protocol

+ #RANGEA  
각 위성의 PRN, Frequency별 **Pseudorange 및 거리정보**가 담긴 ASCII Protocol  

+ #BESTXYZA  
**수신기의 XYZ좌표**가 담긴 비교용 ASCII Protocol  

이후 최소제곱법을 이용해 계산

<p align="center">
<img src="https://user-images.githubusercontent.com/50317129/62348861-03060400-b539-11e9-93d1-f93fc77a3945.png" alt="LeastSquare" title="LeastSquare">
</p>

계산 방식의 대략적인 개념은 위 그림과 같다  
아직 수신기의 위치를 모르니, 임의의 초기값(보통 0)을 지정하여 해당 지점으로부터 오차를 줄여나가 수렴하는 점을 계산한다.  
일정 계산 이후 보통 하나의 점으로 수렴하는데, 이 점이 **수신기의 위치**  

계산 수식은 그림으로 찍어야 하는데 어차피 나만 볼 거 귀찮다  

<p align="center">
<img src="https://user-images.githubusercontent.com/50317129/62348931-3ba5dd80-b539-11e9-8a9f-1a7a2f7bb7ed.png" alt="Correction" title="Correction">
</p>

오차 보정방식은 위 그림과 같다  
보통 위성은 중궤도에 위치하는데, 이로 인해 위성이 커버할 수 있는 지역이 매우 넓다. **정해진 지역에서 관측할 수 있는 위성의 수 역시 비슷하고 오차 또한 비슷**하다(평지 기준)  
조건에 따라 다르지만 한 80km 정도?  
VRS 사용해봤을 때, 천안 수신국에서 관측하는 위성과 내 학교 랩실에서 관측하는 위성의 수와 PRN이 거의 동일했다  

<p align="center">
<img src="https://user-images.githubusercontent.com/50317129/62348898-22049600-b539-11e9-89c2-8e85104bb28d.png" alt="Algorithm" title="Algorithm">
</p>

전체적인 알고리즘은 위 그림과 같다  
두 개의 수신기를 통해 동일한 시간동안 데이터를 수집한다. 기준국과 외부 수신국으로 나뉘며, 기준국의 데이터는 정확할 수록 좋다.  
**외부 수신국의 위치를 단독측위를 통해 계산**하고, **기준국의 데이터를 역으로 계산하여 오차**를 구한다.  
이후 이 **오차를 외부 수신국의 위치에 반영하여 계산**하여 DGPS를 구성  

### GPS 단독측위

<p align="center">
<img src="https://user-images.githubusercontent.com/50317129/62348957-4f514400-b539-11e9-8db6-fe1cbdc09cd1.png" alt="SinglePosition" title="SinglePosition">
</p>

### DGPS

<p align="center">
<img src="https://user-images.githubusercontent.com/50317129/62348963-524c3480-b539-11e9-9e14-d89aa5cb973c.png" alt="DGPS" title="SGPS">
</p>

Grahp의 (0 ,0)이 수신기의 정확한 위치이며, Graph의 점은 계산된 위치  
단독측위로도 어느정도 정밀성이 있지만, 오프셋이 발생하여 정확성은 떨어진다.
DGPS적용 시 오프셋이 사라져 정밀성과 정확성 약간 상승

MATLAB Library를 통해 결과값을 Google에 Mapping할 수도 있으며, 결과값은 맨 위 사진과 같다. (위 Graph와 동일한 데이터는 아님)  

---

이론이나 결과값은 어디까지나 비전공 학부생 수준이라, 전공가나 관련업계 종사자가 보면 비웃을 것 같다  
하긴 전기공학과가 저런거 하고 있으면 나같아도 웃을듯  
근데 전기보다 저게 더 재밌었다  

학부생 시절엔 Programming을 잘 알지 못해 무식하게 MATLAB Script에 관련 동작을 전부 때려박았다.
지금 다시 제작하라고 한다면 데이터 전처리는 MATLAB으로 진행하고, 정제된 데이터를 C#으로 UI를 구성하여 처리하는 프로그램을 만들어 더욱 깔끔하게 제작하지 않을까 한다.  
물론 저거 다시 제작할 수 있냐고 하면 쉽지 않을 것 같다...  

---
수업 이전에 공학자로써의 가치를 가르쳐주신 **조정호 교수님**  
지금은 공기업으로 이직하신 (전) 인성 인터네셔널 **권상수 과장님**  
얼굴도 모르는 일개 학부생에게 많은 도움을 준 넵코어스 **손석보 과장님**  
남들 데이터 달라는 질문 사이로 뜬금없이 기술적인 질문으로 내가 귀찮게 군 **한국해양측위정보원**  
모자란 영어에도 성심성의껏 답변해준 NovAtel Msc EE. **Richard Gutteling**과 다른 Engineer분들  
마찬가지로, 모자란 영어에도 많은 답변을 주고, PPP서비스로 정밀측위 데이터를 쉽게 얻을 수 있도록 도와준 **Canada RNCAN**  
<p align="center">
.
</p>
<p align="center">
.
</p>
<p align="center">
.
</p>

**전역 후, 앞이 안 보였던 내 미래를 바꾸기 위해 랩실에 첫 발을 내딘 22살의 나를 기억하며.** 

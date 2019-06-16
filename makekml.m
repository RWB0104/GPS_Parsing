% 찾다찾다 없어서 직접 만드는 GPS Parsing 한글패치판
%
% 순천향대 전기공학과 박성진
%
% Google Earth Mapping 알고리즘
%
% ==================================================
% INPUT
%
% llh = 위도, 경도, 높이 (WGS-84 도형태)
% ==================================================
%
% ==================================================
% OUTPUT
%
% .kml = Google Earth .KML파일 (MATLAB 결과 출력이 아님)
% ==================================================

function makekml(llh)

% llh(:,3)=5;

gps_line=ge_plot3(llh(:,2), llh(:,1), llh(:,3), 'lineWidth',3, ...
    'lineColor','FF00FF00', ...
    'altitudeMode', 'relativeToGround', ...
    'extrude', 0, ...
    'description', 'Test');
% 이동경로 그리는 파트
% 항목마다 사용자에 따라 세부사항 수정 가능

icon='http://maps.google.com/mapfiles/kml/shapes/road_shield3.png';

gps_point=ge_point_new(llh(:,2), llh(:,1), llh(:,3), 'iconURL',icon, ...
    'iconColor','FF00FF00', ...
    'iconScale', 0.3, ...
    'timeStamp', 5);
% 이동점 찍는 파트
% 항목마다 사용자에 따라 세부사항 수정 가능

ge_output('Result.kml',[gps_line, gps_point]);
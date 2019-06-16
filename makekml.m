% ã��ã�� ��� ���� ����� GPS Parsing �ѱ���ġ��
%
% ��õ��� ������а� �ڼ���
%
% Google Earth Mapping �˰���
%
% ==================================================
% INPUT
%
% llh = ����, �浵, ���� (WGS-84 ������)
% ==================================================
%
% ==================================================
% OUTPUT
%
% .kml = Google Earth .KML���� (MATLAB ��� ����� �ƴ�)
% ==================================================

function makekml(llh)

% llh(:,3)=5;

gps_line=ge_plot3(llh(:,2), llh(:,1), llh(:,3), 'lineWidth',3, ...
    'lineColor','FF00FF00', ...
    'altitudeMode', 'relativeToGround', ...
    'extrude', 0, ...
    'description', 'Test');
% �̵���� �׸��� ��Ʈ
% �׸񸶴� ����ڿ� ���� ���λ��� ���� ����

icon='http://maps.google.com/mapfiles/kml/shapes/road_shield3.png';

gps_point=ge_point_new(llh(:,2), llh(:,1), llh(:,3), 'iconURL',icon, ...
    'iconColor','FF00FF00', ...
    'iconScale', 0.3, ...
    'timeStamp', 5);
% �̵��� ��� ��Ʈ
% �׸񸶴� ����ڿ� ���� ���λ��� ���� ����

ge_output('Result.kml',[gps_line, gps_point]);
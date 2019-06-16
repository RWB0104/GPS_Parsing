%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% variables                                      %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 수신기별 데이터 정의
NPS.COUNT = 0;
NPS.GPSTIME = 0;
NPS.TIMESTEP = 0.5;
NPS.MODE = 0;
NPS.ReFLAGS = ones(1,NumOfReceiver);                        % 매 에폭마다 초기화
NPS.TIMEGAP = NaN(1,NumOfReceiver);                         % 매 에폭마다 초기화
NPS.IoB = 0;                                                % NPS 백업 인덱스

% 궤도력 관련 설정
initEPH = struct('PRN', [], 'TOCYear', [], 'TOCMonth', [], 'TOCDay', [], 'TOCHour', [], 'TOCMinute', [], 'TOCSecond', [], ...
                 'TOC', [], 'af0', [], 'af1', [], 'af2', [], 'IODE', [], 'Crs', [], 'Delta_n', [], 'M0', [], 'Cuc', [], ...
                 'e', [], 'Cus', [], 'sqrt_A', [], 'TOE', [], 'Cic', [], 'OMEGA0', [], 'Cis', [], 'i0', [], 'Crc', [], ...
                 'omega', [], 'OMEGA_DOT', [], 'IDOT', [], 'CodesOnL2Channel', [], 'GPSWeek', [], 'L2PDataFlag', [], ...
                 'SVAccuracy', [], 'SVHealth', [], 'TGD', [], 'IODC', [], 'GPSSecT', [], 'GPSWeekT', [], 'FitInterval', []);
NPS.EPH = repmat(struct(initEPH), CONST_GPS_PRNmax, NoE);   % (초기 인덱스 설정: ... 열 NoE-2:전 시간대 , 열 NoE-1:현재 시간대, 열 NoE: 다음 시간대)
NPS.IoE = NoE - 1;                                          % 각 위성별 궤도력 데이터 현재 위치값

% 
for k=1:NumOfReceiver
    NST(k).CONF = struct;
    NST(k).EPOCH = struct;
    NST(k).BackupEPOCH = cell(NoB, 1);
    NST(k).BackupDATA = cell(NoB, 1);
    NST(k).IoB = 0;
    NST(k).BufferEPH = [];                                  % 궤도력 데이터 임시 장소
%     NST(k).CONF = struct('MODEL', [], 'ANT', [], 'STARTTIME', [], 'INTERVAL', [], 'MASK', []);
%     NST(k).EPOCH = struct('COUNT', [], 'GPSTIME', [], 'GPSWEEK', [], 'GPSSECOND', [], ...
%                           'UTCYEAR', [], 'UTCMONTH', [], 'UTCDAY', [], 'UTCHOUR', [], 'UTCMINUTH', [], 'UTCSECOND', [], ...
%                           'FLAG', [], 'CLKOFFSET', [], 'NoSV', [], 'XYZB' , [], 'ENU' , []);
    preSmoothing{k} = NaN(CONST_GPS_PRNmax, COL_pSD_MAX);
end

% 
FID_Logging = fopen('.\RESULTS\results_20080623.txt', 'wt');% 결과 저장 파일

% 
% 수동 정의 <- dialog box 입력 창으로 대체(함수로), 아래 내용은 디폴트 선택 값, 여러 조건 적용
NST(1).NAME = 'User';                                       % 1번 사용자
NST(1).FID = fopen('.\DATA_FILES\test1_20080623.gps', 'r');
% NST(1).FID = fopen('.\DATA_FILES\test0_20080711.gps', 'r');
% NST(1).FID = fopen('.\DATA_FILES\test1_2008070910.gps', 'r');
% NST(1).FID = fopen('.\DATA_FILES\KARI_KAU\KAU_2008082811_2008082912.gps', 'r');
% NST(1).FID = fopen('.\DATA_FILES\test1_2008081215.gps', 'r');
% NST(1).FID = fopen('.\DATA_FILES\test_rov_20081010_1.gps', 'r');
% NST(1).FID = fopen('.\DATA_FILES\test_rov_20081010_2.gps', 'r');
% NST(1).FID = fopen('.\DATA_FILES\test_rov_20081027_1.gps', 'r');
% NST(1).FID = fopen('.\DATA_FILES\test_rov_20081027_2.gps', 'r');
% NST(1).FID = fopen('.\DATA_FILES\test_rov_20081027_3.gps', 'r');
% NST(1).FID = struct('O', fopen('.\DATA_FILES\XXXX.08O', 'r'), 'N', fopen('.\DATA_FILES\XXXX.08N', 'r'));
NST(1).CONF.MODEL       = MODEL_DLV3_PP;
% NST(1).CONF.MODEL       = MODEL_DLV3_PP_mat01;  % test1_2008070910.gps의 mat 파일
% NST(1).CONF.MODEL       = MODEL_DLV3_PP_mat02;  % test1_2008071215.gps의 mat 파일
% NST(1).CONF.MODEL       = MODEL_DLV3_PP_mat03;  % test1_20081010_1.gps의 mat 파일
% NST(1).CONF.MODEL       = MODEL_DLV3_PP_mat04;  % test1_20081010_2.gps의 mat 파일
% NST(1).CONF.MODEL       = MODEL_DLV3_PP_mat05;  % test1_20080623.gps의 mat 파일
NST(1).CONF.ANT         = ANT_GPS702GGL;
NST(1).CONF.STARTTIME   = NaN;                              % 파일 선택되면, 최초 시간 디폴트(단위: s, UTC로 중간 시간 설정 가능)
NST(1).CONF.INTERVAL    = 0.5;                              % 파일 선택되면, 자동 설정
NST(1).CONF.MASK        = 5*pi/180;                         % Mask angle, radian

NST(2).NAME = 'Master_01';                                  % 2번부터 참조 수신기
NST(2).FID = fopen('.\DATA_FILES\test2_20080623.gps', 'r');
% NST(2).FID = fopen('.\DATA_FILES\test1_20080711.gps', 'r');
% NST(2).FID = fopen('.\DATA_FILES\test2_2008070910.gps', 'r');
% NST(2).FID = fopen('.\DATA_FILES\KARI_KAU\KARI_2008082811_2008082912.gps', 'r');
% NST(2).FID = fopen('.\DATA_FILES\test2_2008081215.gps', 'r');
% NST(2).FID = fopen('.\DATA_FILES\test_ref_20081010.gps', 'r');
% NST(2).FID = fopen('.\DATA_FILES\test_ref_20081027.gps', 'r');
% NST(2).FID = struct('O', fopen('.\DATA_FILES\XXXX.08O', 'r'), 'N', fopen('.\DATA_FILES\XXXX.08N', 'r'));
NST(2).CONF.MODEL       = MODEL_DLV3_PP;
% NST(2).CONF.MODEL       = MODEL_DLV3_PP_mat01;  % test2_2008070910.gps의 mat 파일
% NST(2).CONF.MODEL       = MODEL_DLV3_PP_mat02;  % test2_2008081215.gps의 mat 파일
% NST(2).CONF.MODEL       = MODEL_DLV3_PP_mat03;  % test_ref_20081010.gps, test1_20081010_1.gps의 mat 파일
% NST(2).CONF.MODEL       = MODEL_DLV3_PP_mat04;  % test_ref_20081010.gps, test1_20081010_2.gps의 mat 파일
% NST(2).CONF.MODEL       = MODEL_DLV3_PP_mat05;  % test2_20080623.gps의 mat 파일
NST(2).CONF.ANT         = ANT_GPS702GGL;
NST(2).CONF.STARTTIME   = NaN;                              % 동일하게 설정할려면, 체크박스로 설정 가능하게 구현
NST(2).CONF.INTERVAL    = 0.5;
NST(2).CONF.MASK        = 5*pi/180;

% QM 관련 데이터 초기화
QMData = cell(1, NumOfReceiver);
for k=1:NumOfReceiver
    QMData{k} = NaN(CONST_GPS_PRNmax, COL_QM_DATA_MAX);
end

QMThresholdsDataFile = cell(1,COL_QM_MAX);                  %  추후 행에 수신기별(또는 수신기 종류별) threshold로 확장
QMThresholdsDataFile{1, COL_QM_CN0avg}  = '.\DATA_FILES\QMThresholdsData\QM_Th_DLV3_CN0avg.txt';
QMThresholdsDataFile{1, COL_QM_CmCD}    = '.\DATA_FILES\QMThresholdsData\QM_Th_DLV3_CmCD.txt';
QMThresholdsDataFile{1, COL_QM_LT}      = '.\DATA_FILES\QMThresholdsData\QM_Th_DLV3_LT.txt';
QMThresholdsDataFile{1, COL_QM_Acc}     = '.\DATA_FILES\QMThresholdsData\QM_Th_DLV3_Acc.txt';
QMThresholdsDataFile{1, COL_QM_Ramp}    = '.\DATA_FILES\QMThresholdsData\QM_Th_DLV3_Ramp.txt';
QMThresholdsDataFile{1, COL_QM_Step}    = '.\DATA_FILES\QMThresholdsData\QM_Th_DLV3_Step.txt';
QMThresholdsDataFile{1, COL_QM_CSCI}    = '.\DATA_FILES\QMThresholdsData\QM_Th_DLV3_CSCI.txt';

QMThresholds = cell(1, COL_QM_MAX);                         %  추후 행에 수신기별(또는 수신기 종류별) threshold로 확장
for k=1:COL_QM_MAX
    QMThresholds{1, k} = load(QMThresholdsDataFile{1, k});
end

% 항법 알고리즘 부분 초기화
P_SD = [];
Nhat_SD = [];
N0_SD = [];
delNhat_SD = [];
ClockBias_SD = 0;
FilteringTime_SD = 0;

P_SD_L1L2 = [];
Nhat_SD_L1L2 = [];
N0_SD_L1L2 = [];
delNhat_SD_L1L2 = [];
ClockBias_SD_L1L2 = 0;
FilteringTime_SD_L1L2 = 0;

% Raw Data의 mat 파일 저장 관련 변수(option)
mat_count_max = 7200;
mat_data = repmat(struct('EPOCH', [], 'DATA', [], 'BufferEPH', [], 'FileEnd', []), mat_count_max, NumOfReceiver);
mat_count = zeros(1, NumOfReceiver);
mat_file_count = zeros(1, NumOfReceiver);

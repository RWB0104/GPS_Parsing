%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% variables                                      %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ���ű⺰ ������ ����
NPS.COUNT = 0;
NPS.GPSTIME = 0;
NPS.TIMESTEP = 0.5;
NPS.MODE = 0;
NPS.ReFLAGS = ones(1,NumOfReceiver);                        % �� �������� �ʱ�ȭ
NPS.TIMEGAP = NaN(1,NumOfReceiver);                         % �� �������� �ʱ�ȭ
NPS.IoB = 0;                                                % NPS ��� �ε���

% �˵��� ���� ����
initEPH = struct('PRN', [], 'TOCYear', [], 'TOCMonth', [], 'TOCDay', [], 'TOCHour', [], 'TOCMinute', [], 'TOCSecond', [], ...
                 'TOC', [], 'af0', [], 'af1', [], 'af2', [], 'IODE', [], 'Crs', [], 'Delta_n', [], 'M0', [], 'Cuc', [], ...
                 'e', [], 'Cus', [], 'sqrt_A', [], 'TOE', [], 'Cic', [], 'OMEGA0', [], 'Cis', [], 'i0', [], 'Crc', [], ...
                 'omega', [], 'OMEGA_DOT', [], 'IDOT', [], 'CodesOnL2Channel', [], 'GPSWeek', [], 'L2PDataFlag', [], ...
                 'SVAccuracy', [], 'SVHealth', [], 'TGD', [], 'IODC', [], 'GPSSecT', [], 'GPSWeekT', [], 'FitInterval', []);
NPS.EPH = repmat(struct(initEPH), CONST_GPS_PRNmax, NoE);   % (�ʱ� �ε��� ����: ... �� NoE-2:�� �ð��� , �� NoE-1:���� �ð���, �� NoE: ���� �ð���)
NPS.IoE = NoE - 1;                                          % �� ������ �˵��� ������ ���� ��ġ��

% 
for k=1:NumOfReceiver
    NST(k).CONF = struct;
    NST(k).EPOCH = struct;
    NST(k).BackupEPOCH = cell(NoB, 1);
    NST(k).BackupDATA = cell(NoB, 1);
    NST(k).IoB = 0;
    NST(k).BufferEPH = [];                                  % �˵��� ������ �ӽ� ���
%     NST(k).CONF = struct('MODEL', [], 'ANT', [], 'STARTTIME', [], 'INTERVAL', [], 'MASK', []);
%     NST(k).EPOCH = struct('COUNT', [], 'GPSTIME', [], 'GPSWEEK', [], 'GPSSECOND', [], ...
%                           'UTCYEAR', [], 'UTCMONTH', [], 'UTCDAY', [], 'UTCHOUR', [], 'UTCMINUTH', [], 'UTCSECOND', [], ...
%                           'FLAG', [], 'CLKOFFSET', [], 'NoSV', [], 'XYZB' , [], 'ENU' , []);
    preSmoothing{k} = NaN(CONST_GPS_PRNmax, COL_pSD_MAX);
end

% 
FID_Logging = fopen('.\RESULTS\results_20080623.txt', 'wt');% ��� ���� ����

% 
% ���� ���� <- dialog box �Է� â���� ��ü(�Լ���), �Ʒ� ������ ����Ʈ ���� ��, ���� ���� ����
NST(1).NAME = 'User';                                       % 1�� �����
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
% NST(1).CONF.MODEL       = MODEL_DLV3_PP_mat01;  % test1_2008070910.gps�� mat ����
% NST(1).CONF.MODEL       = MODEL_DLV3_PP_mat02;  % test1_2008071215.gps�� mat ����
% NST(1).CONF.MODEL       = MODEL_DLV3_PP_mat03;  % test1_20081010_1.gps�� mat ����
% NST(1).CONF.MODEL       = MODEL_DLV3_PP_mat04;  % test1_20081010_2.gps�� mat ����
% NST(1).CONF.MODEL       = MODEL_DLV3_PP_mat05;  % test1_20080623.gps�� mat ����
NST(1).CONF.ANT         = ANT_GPS702GGL;
NST(1).CONF.STARTTIME   = NaN;                              % ���� ���õǸ�, ���� �ð� ����Ʈ(����: s, UTC�� �߰� �ð� ���� ����)
NST(1).CONF.INTERVAL    = 0.5;                              % ���� ���õǸ�, �ڵ� ����
NST(1).CONF.MASK        = 5*pi/180;                         % Mask angle, radian

NST(2).NAME = 'Master_01';                                  % 2������ ���� ���ű�
NST(2).FID = fopen('.\DATA_FILES\test2_20080623.gps', 'r');
% NST(2).FID = fopen('.\DATA_FILES\test1_20080711.gps', 'r');
% NST(2).FID = fopen('.\DATA_FILES\test2_2008070910.gps', 'r');
% NST(2).FID = fopen('.\DATA_FILES\KARI_KAU\KARI_2008082811_2008082912.gps', 'r');
% NST(2).FID = fopen('.\DATA_FILES\test2_2008081215.gps', 'r');
% NST(2).FID = fopen('.\DATA_FILES\test_ref_20081010.gps', 'r');
% NST(2).FID = fopen('.\DATA_FILES\test_ref_20081027.gps', 'r');
% NST(2).FID = struct('O', fopen('.\DATA_FILES\XXXX.08O', 'r'), 'N', fopen('.\DATA_FILES\XXXX.08N', 'r'));
NST(2).CONF.MODEL       = MODEL_DLV3_PP;
% NST(2).CONF.MODEL       = MODEL_DLV3_PP_mat01;  % test2_2008070910.gps�� mat ����
% NST(2).CONF.MODEL       = MODEL_DLV3_PP_mat02;  % test2_2008081215.gps�� mat ����
% NST(2).CONF.MODEL       = MODEL_DLV3_PP_mat03;  % test_ref_20081010.gps, test1_20081010_1.gps�� mat ����
% NST(2).CONF.MODEL       = MODEL_DLV3_PP_mat04;  % test_ref_20081010.gps, test1_20081010_2.gps�� mat ����
% NST(2).CONF.MODEL       = MODEL_DLV3_PP_mat05;  % test2_20080623.gps�� mat ����
NST(2).CONF.ANT         = ANT_GPS702GGL;
NST(2).CONF.STARTTIME   = NaN;                              % �����ϰ� �����ҷ���, üũ�ڽ��� ���� �����ϰ� ����
NST(2).CONF.INTERVAL    = 0.5;
NST(2).CONF.MASK        = 5*pi/180;

% QM ���� ������ �ʱ�ȭ
QMData = cell(1, NumOfReceiver);
for k=1:NumOfReceiver
    QMData{k} = NaN(CONST_GPS_PRNmax, COL_QM_DATA_MAX);
end

QMThresholdsDataFile = cell(1,COL_QM_MAX);                  %  ���� �࿡ ���ű⺰(�Ǵ� ���ű� ������) threshold�� Ȯ��
QMThresholdsDataFile{1, COL_QM_CN0avg}  = '.\DATA_FILES\QMThresholdsData\QM_Th_DLV3_CN0avg.txt';
QMThresholdsDataFile{1, COL_QM_CmCD}    = '.\DATA_FILES\QMThresholdsData\QM_Th_DLV3_CmCD.txt';
QMThresholdsDataFile{1, COL_QM_LT}      = '.\DATA_FILES\QMThresholdsData\QM_Th_DLV3_LT.txt';
QMThresholdsDataFile{1, COL_QM_Acc}     = '.\DATA_FILES\QMThresholdsData\QM_Th_DLV3_Acc.txt';
QMThresholdsDataFile{1, COL_QM_Ramp}    = '.\DATA_FILES\QMThresholdsData\QM_Th_DLV3_Ramp.txt';
QMThresholdsDataFile{1, COL_QM_Step}    = '.\DATA_FILES\QMThresholdsData\QM_Th_DLV3_Step.txt';
QMThresholdsDataFile{1, COL_QM_CSCI}    = '.\DATA_FILES\QMThresholdsData\QM_Th_DLV3_CSCI.txt';

QMThresholds = cell(1, COL_QM_MAX);                         %  ���� �࿡ ���ű⺰(�Ǵ� ���ű� ������) threshold�� Ȯ��
for k=1:COL_QM_MAX
    QMThresholds{1, k} = load(QMThresholdsDataFile{1, k});
end

% �׹� �˰��� �κ� �ʱ�ȭ
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

% Raw Data�� mat ���� ���� ���� ����(option)
mat_count_max = 7200;
mat_data = repmat(struct('EPOCH', [], 'DATA', [], 'BufferEPH', [], 'FileEnd', []), mat_count_max, NumOfReceiver);
mat_count = zeros(1, NumOfReceiver);
mat_file_count = zeros(1, NumOfReceiver);

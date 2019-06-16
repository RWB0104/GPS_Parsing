%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init_QM                                        %
%                                                %
% Version: 1.0_20080808                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global CON_PolyOrder
global COL_QM_CN0avg COL_QM_CmCD COL_QM_LockTime COL_QM_Acc COL_QM_Ramp COL_QM_Step ...
       COL_QM_CSCI COL_QM_max
global COL_QM_data_GPStime COL_QM_data_CA COL_QM_data_preCA COL_QM_data_preCAs COL_QM_data_preCAsCount ...
       COL_QM_data_L1 COL_QM_data_preL1 COL_QM_data_L1corr10 COL_QM_data_CN0L1 ...
       COL_QM_data_preCN0L1 COL_QM_data_LockTimeL1 COL_QM_data_preLockTimeL1 COL_QM_data_EL ...
       COL_QM_data_CN0avg COL_QM_data_CmCD COL_QM_data_preCmCD ...
       COL_QM_data_Acc COL_QM_data_Ramp COL_QM_data_Step COL_QM_data_CSCI COL_QM_data_max
global COL_QM_Th_mean COL_QM_Th_coefficient COL_QM_Th_maxEL COL_QM_Th_max
% global COL_DATA_CN0avgTest COL_DATA_CmCDTest COL_DATA_AccTest COL_DATA_RampTest COL_DATA_StepTest ...
%        COL_DATA_CSCITest COL_DATA_flagtemp COL_DATA_max

CON_PolyOrder = 5;

% 초기화
% COL_DATA_CN0avgTest  = 34;       % QM Test flag: 0(No fault signal)
% COL_DATA_CmCDTest    = 35;       % QM Test flag: 0(No fault signal)
% COL_DATA_AccTest     = 36;       % QM Test flag: 0(No fault signal)
% COL_DATA_RampTest    = 37;       % QM Test flag: 0(No fault signal)
% COL_DATA_StepTest    = 38;       % QM Test flag: 0(No fault signal)
% COL_DATA_CSCITest    = 39;       % QM Test flag: 0(No fault signal)
% COL_DATA_flagtemp    = 40;       % QM Test flag: 0(No fault signal)
% COL_DATA_max         = 40;

COL_QM_CN0avg           = 1;        % 
COL_QM_CmCD             = 2;        % 
COL_QM_LockTime         = 3;        % 
COL_QM_Acc              = 4;        % 
COL_QM_Ramp             = 5;        % 
COL_QM_Step             = 6;        % 
COL_QM_CSCI             = 7;        % 
COL_QM_max              = 7;        % 

COL_QM_data_GPStime     = 1;        % 
COL_QM_data_CA          = 2;        % 
COL_QM_data_preCA       = 3;        % 
COL_QM_data_preCAs      = 4;        % 
COL_QM_data_preCAsCount = 5;        % 
COL_QM_data_L1          = 6;        % 
COL_QM_data_preL1       = 7;        % 
COL_QM_data_L1corr10    = 8:17;     % 
COL_QM_data_CN0L1       = 18;       % 
COL_QM_data_preCN0L1    = 19;       % 
COL_QM_data_LockTimeL1  = 20;       % 
COL_QM_data_preLockTimeL1 = 21;     % 
COL_QM_data_EL          = 22;       % 
%-----------------------------------% 
COL_QM_data_CN0avg      = 23;       % 
COL_QM_data_CmCD        = 24;       % 
COL_QM_data_preCmCD     = 25;       % 
COL_QM_data_Acc         = 26;       % 
COL_QM_data_Ramp        = 27;       % 
COL_QM_data_Step        = 28;       % 
COL_QM_data_CSCI        = 29;       % 
COL_QM_data_max         = 29;       % 

COL_QM_Th_mean          = 1;                    % 
COL_QM_Th_coefficient   = 2:(CON_PolyOrder+2);  % 
COL_QM_Th_maxEL         = CON_PolyOrder+3;      % 
COL_QM_Th_max           = CON_PolyOrder+3;      % 

QM_ThresholdsData_file = cell(1,COL_QM_max);
QM_ThresholdsData_file{1, COL_QM_CN0avg}   = '.\QM_ThresholdsData\QM_ThresholdsData_CN0avg.txt';
QM_ThresholdsData_file{1, COL_QM_CmCD}     = '.\QM_ThresholdsData\QM_ThresholdsData_CmCD.txt';
QM_ThresholdsData_file{1, COL_QM_LockTime} = '.\QM_ThresholdsData\QM_ThresholdsData_LockTime.txt';
QM_ThresholdsData_file{1, COL_QM_Acc}      = '.\QM_ThresholdsData\QM_ThresholdsData_Acc.txt';
QM_ThresholdsData_file{1, COL_QM_Ramp}     = '.\QM_ThresholdsData\QM_ThresholdsData_Ramp.txt';
QM_ThresholdsData_file{1, COL_QM_Step}     = '.\QM_ThresholdsData\QM_ThresholdsData_Step.txt';
QM_ThresholdsData_file{1, COL_QM_CSCI}     = '.\QM_ThresholdsData\QM_ThresholdsData_CSCI.txt';

QM_data = cell(NumOfReceiver, 1);
for k=1:NumOfReceiver, QM_data{k, 1} = NaN(CON_GPS_PRNmax,COL_QM_data_max); end
QM_thresholds = cell(1, COL_QM_max);            %  추후 행에 수신기별(또는 수신기 종류별) threshold로 확장
for k=1:COL_QM_max, QM_thresholds{1, k} = load(QM_ThresholdsData_file{1, k}); end

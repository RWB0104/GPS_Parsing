%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RTK (KARI, NST)                                %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 초기화
clear all;
close all;
clc;

% 실행 시간 설정
NumOfReceiver = 2;      % 수신기 수 : 현재 2까지만 가능, 3 이상은 init_variables.m에서 수동 설정이 필요하며, 이 경우를 고려하여 프로그램 하였으나 추가적인 수정이 있을 수 있음
% EoE = 7200*2;                % 설정한 값만큼 실행(0: 데이터 끝까지)
% EoE = 0;                % 설정한 값만큼 실행(0: 데이터 끝까지)
EoE = 60*2*20;                % 설정한 값만큼 실행(0: 데이터 끝까지)
EoF = 0;                % 파일 끝 체크 변수 초기화
NoB = 10;               % 데이터 백업 ephoch 수(10 이상)
NoE = 12*3 + 2;         % Ephemeris 백업 데이터 저장 수(단위: 2시간, 3 이상) <- 2시간 단위 가정으로 이 외의 경우를 고려할 경우에는 수정이 필요할 수 있음
                        % (+2는 다음시간대 +1과 추가적인 빈 공간 +1)
NPS = struct; BackupNPS = cell(NoB, 1);
NST = repmat(struct, 1, NumOfReceiver);
preSmoothing = cell(1, NumOfReceiver);          % 스무딩 계산을 위한 백업
FileEnd = zeros(1, NumOfReceiver);

FilteringPeriod = 3*60;                         % 필터링 주기 설정 (단위: 초)

init_const;
init_col_labels;
init_variables;     % 해당 파일 이름은 여기서 설정, 현재 형태는 미완성으로 추후 보완 예정

FlagSaveMat = 0;    % 빠른 실행을 위한 읽는 부분 Matlab 저장 변수 mat 파일로의 저장 플래그(1: 실행)
                    % 1로 실행할 경우, save_mat_NovAtel 함수에서 저장파일 경로 및 변수명 부분 수동 수정 필요
zzz0 = cell(1, NumOfReceiver);  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 초기 실행 : 데이터 읽음(초기시간 동기: 옵션), 초기 위치 계산
% 초기 데이터 읽음
EoE_temp = EoE; EoE = 0;    % 초기시간 동기 구간에서는 설정값 체크 안함(mat 파일 저장에 사용)
NPS.COUNT = 1;disp(['Init Processing...  ', num2str(NPS.COUNT)]);
temp01 = NaN(1,NumOfReceiver*2);
for k=1:NumOfReceiver
    read_RAW;
    
    temp01(k) = NST(k).EPOCH.GPSTIME;               % 로깅 데이터의 처음 시간
    temp01(k+NumOfReceiver) = NST(k).CONF.STARTTIME;% 설정된 처음 시간
end
NPS.GPSTIME = min(temp01);
temp02 = max(temp01);

for k=1:NumOfReceiver                               % 처음 저장은 현재 시간이 저장된 후에 실행
    % 빠른 실행을 위한 읽는 부분 Matlab 저장 변수 mat 파일로의 저장(끝나는 시점에 대한 수정이 있는 경우는 이 함수 내용도 수정이 필요)
    if FlagSaveMat && (NST(k).CONF.MODEL == MODEL_DLV3_PP), save_mat_NovAtel; end
end

% 수신기별 시간 동기 위한 데이터 읽음(<- 시각 동기 전의 데이터 처리도 가능)
if NPS.GPSTIME == temp02                            % 처음 데이터가 동기가 되어 있는 경우
    NPS.ReFLAGS = zeros(1,NumOfReceiver);
else
    while sum(NPS.ReFLAGS)      %%%%%%%%%% 여러 기준국을 고려하는 경우 수정 가능 있음 %%%%%%%%%%
        NPS.COUNT = NPS.COUNT + 1;disp(['Init Processing...  ', num2str(NPS.COUNT), '  ', num2str(NPS.ReFLAGS(1)), '  ', num2str(NPS.ReFLAGS(2))]);
        NPS.GPSTIME = NPS.GPSTIME + NPS.TIMESTEP;
        NPS.ReFLAGS = ones(1,NumOfReceiver);
        for k=1:NumOfReceiver
            if (NST(k).EPOCH.GPSTIME < temp02) && (NST(k).EPOCH.GPSTIME < NPS.GPSTIME) && (FileEnd(k) == 0)
                read_RAW;                           % 읽은 데이터가 설정시간 전이면, 다음 데이터 읽음
            end
            
            % 빠른 실행을 위한 읽는 부분 Matlab 저장 변수 mat 파일로의 저장(끝나는 시점에 대한 수정이 있는 경우는 이 함수 내용도 수정이 필요)
            if FlagSaveMat && (NST(k).CONF.MODEL == MODEL_DLV3_PP), save_mat_NovAtel; end
            
            if NST(k).EPOCH.GPSTIME > temp02        % 설정시간에 데이터가 없는 경우 설정시간 갱신
                temp02 = NST(k).EPOCH.GPSTIME;
            elseif NST(k).EPOCH.GPSTIME == temp02   % 설정시간의 데이터 유무 체크
                NPS.ReFLAGS(k) = 0;                 % 0: OK, 1: fail, > 1: option
            end
        end
%         [NPS.GPSTIME, NST(1).EPOCH.GPSTIME, NST(2).EPOCH.GPSTIME]
    end
end

% 초기 위치 계산
for k=1:NumOfReceiver
    NST(k).CONF.STARTTIME = NPS.GPSTIME;            % 시작 시간 저장
    
    % 궤도력 데이터 검증 및 배치
    % (궤도력 사용 및 백업: 현재는 같은 시간대의 데이터는 최근 데이터를 사용하며, 사용 데이터는 BackupEPH 1열에 저장하고, 기존 데이터는 2열에 저장)
    while ~isempty(NST(k).BufferEPH)                % 일반적인 2시간 단위 갱신을 가정한 것으로 그 외의 경우(예, 1시간 단위 갱신 등)를 고려할 경우는 수정이 필요
%         % 현재 시간 기준 2시간 단위 카운터 수와 궤도력 시간 카운터 수 계산
%         No2hours_S = floor(NPS.GPSTIME / (60*60*2));
%         No2hours_E = floor((NST(k).BufferEPH(1).GPSWeek*60*60*24*7 + NST(k).BufferEPH(1).TOE+60) / (60*60*2));          % TOE+60은 59분 28초, 44초의 경우에 대한 보정
% %         No2hours_E = floor((NST(k).BufferEPH(1).GPSWeek*60*60*24*7 + NST(k).BufferEPH(1).TOE+60 + 60*60) / (60*60*2));  % TOE+60은 59분 28초, 44초의 경우에 대한 보정, 홀수 시간대에서 끊는 경우(+1시간으로 설정, 1~3시는 TOE 2시 데이터 사용)
%         
%         % 메모리 위치 계산(NPS.IoE: 현재 위치값)과 궤도력 데이터 검증 및 배치
%         temp03 = No2hours_E - No2hours_S + NPS.IoE;
%         if (1 <= temp03) && (temp03 <= NoE)         % 초기 궤도력 데이터는 설정 범위 내의 데이터만 저장 (NoE = NPS.IoE + 1)
%             if k==1                                 % 사용자 궤도력만 사용 <- 모든 기준국 포함 궤도력을 사용할 경우는 이 조건문 없앰
%                 if ~isempty(NPS.EPH(NST(k).BufferEPH(1).PRN, temp03).PRN)                       % 데이터가 존재할 때
%                     if NPS.EPH(NST(k).BufferEPH(1).PRN, temp03).TOE > NST(k).BufferEPH(1).TOE   % 완전 동일한 시간이 아니면서 59분 XX초인 경우(같은 시간대는 건너뜀) <- 이 부분은 반대의 경우가 될 수도 있음
%                         % 궤도력 데이터 검증 (초기화 중에 .DQMFlag 추가 필요)
% %                         DQM;
%                         
%                         % 궤도력 검증 부분이 추가될 경우, 이에 대한 조건문 필요
%                         NPS.EPH(NST(k).BufferEPH(1).PRN, temp03) = NST(k).BufferEPH(1);
%                         
%                         % 궤도력 데이터 백업
% %                         No2hours_Y = ;
% %                         No2hours_D = ;
% %                         No2hours_H = ;
% %                         BackupEPH{NST(k).BufferEPH(1).PRN}(, ) = ;
%                     end
%                 else    % 데이터가 존재하지 않는 경우
%                     % 궤도력 데이터 검증 (초기화 중에 .DQMFlag 추가 필요)
% %                     DQM;
%                     
%                     % 궤도력 검증 부분이 추가될 경우, 이에 대한 조건문 필요
%                     NPS.EPH(NST(k).BufferEPH(1).PRN, temp03) = NST(k).BufferEPH(1);
%                     
%                     % 궤도력 데이터 백업
% %                     No2hours_Y = ;
% %                     No2hours_D = ;
% %                     No2hours_H = ;
% %                     BackupEPH{NST(k).BufferEPH(1).PRN}(, ) = ;
%                 end
%             end
%         end
%         
        % 처리된 데이터 제거
        NST(k).BufferEPH(1) = [];
    end
    
    % 위성 위치 계산 : 현재 다음 함수를 실행하지 않는 경우, 수신기에서 계산된 위성 위치값이 사용됨
%     calSVsPos;
    
    % 위치 계산(StandAlone)
    if k==1     % user
%         temp05 = [-3119513.74099720, 4086862.18153458, 3761997.67677431];   % 정확한 값으로 수동 설정
        temp05 = NST(k).EPOCH.XYZB;
    elseif k==2% ref
        temp05 = [-3119514.34400035, 4086861.44802314, 3761998.01570046];
    else
        temp05 = NST(k).EPOCH.XYZB;
    end
    
%     temp05 = olspos(NST(k).DATA(:, COL_DATA_C1C), NST(k).DATA(:, COL_DATA_SVXYZ));
%     temp05 = NST(k).EPOCH.XYZB;
    
%     temp05 = [-3259317.7947776099, 4074192.8785491101, 3656396.7413653401, 0];% 20081010 %%%%%%%%%%%%%%%
%     temp05 = [-3119661.3102082098, 4086992.2425974100, 3761743.2698629298, 0];% 20081027 %%%%%%%%%%%%%%%
%     NST(k).EPOCH.XYZB = temp05;                                               %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    NST(k).XYZB_NSTSD = temp05;
    NST(k).XYZB_NSTDD = temp05;
    NST(k).XYZB_LADGPS = temp05;
    NST(k).XYZB_RGPSSD = temp05;
    NST(k).XYZB_SA = temp05;
    NST(k).XYZB_PE = temp05;
end

UsrPos = NST(1).EPOCH.XYZB(1:3);
RefPos = NST(2).EPOCH.XYZB(1:3);                                    % 첫 번째 기준국을 기준점으로 설정
% UsrPos = temp05(1:3); %%%%%%%%%%%%%%%%%%%%%%%%%%
% RefPos = temp05(1:3); %%%%%%%%%%%%%%%%%%%%%%%%%%

% KARI, KAU
% UsrPos = [-3035387.92654911, 4047988.19623592, 3870472.94625895];   % 정확한 값으로 수동 설정
% RefPos = [-3119514.04733591, 4086861.04481042, 3761998.82500128];

% KARI(20080709 ~ 20080710)
% UsrPos = [-3119513.74099720, 4086862.18153458, 3761997.67677431];   % 정확한 값으로 수동 설정
UsrPos = [-3119516.637174607, 4086863.709305724, 3762000.145357828];    % UsrPos: CDGPS 추정치의 평균으로 수정
RefPos = [-3119514.34400035, 4086861.44802314, 3761998.01570046];
% NST(1).XYZB_NSTSD = [UsrPos, 0];
% NST(2).XYZB_NSTSD = [RefPos, 0];

% KARI(20080812 ~ 20080815)  <- 잘못 구한것으로 추정됨
% UsrPos = [-3119514.19312775, 4086860.98983432, 3761998.76059499];   % 정확한 값으로 수동 설정
% RefPos = [-3119549.37207833, 4086836.52864946, 3761999.60932773];

for k=1:NumOfReceiver                               % 좌표 변환
    temp06 = ecef2enu(NST(k).EPOCH.XYZB(1:3), RefPos);
    NST(k).EPOCH.ENU = temp06;
    NST(k).ENU_NSTSD = temp06;
    NST(k).ENU_NSTDD = temp06;
    NST(k).ENU_LADGPS = temp06;
    NST(k).ENU_RGPSSD = temp06;
    NST(k).ENU_SA = temp06;
    NST(k).ENU_PE = temp06;
end

clear temp*;

% 필터링 관련 초기화
FilteringTime_SD = NPS.GPSTIME - FilteringPeriod;   % 초기 실행을 위한 설정

%% 
EoE = EoE_temp;clear EoE_temp;
NPS.COUNT = 1;disp(['Processing...       ', num2str(NPS.COUNT), '  ', num2str(NPS.ReFLAGS(1)), '  ', num2str(NPS.ReFLAGS(2))]);
while 1
    for k=1:NumOfReceiver
        % GPS외 위성 데이터 제거
        del_PRN = find(NST(k).DATA(:, COL_DATA_PRN) > CONST_GPS_PRNmax);
        if(~isempty(del_PRN)), NST(k).DATA(del_PRN, :) = []; end
%         del_PRN = find(NST(k).DATA(:, COL_DATA_PRN) == 22);
%         if(~isempty(del_PRN)), NST(k).DATA(del_PRN, :) = []; end
        
        % PRN순 데이터 정렬
        NST(k).DATA = sortrows(NST(k).DATA, COL_DATA_PRN);
        
        % 위성 위치 계산 : 현재 다음 함수를 실행하지 않는 경우, 수신기에서 계산된 위성 위치값이 사용됨
%         calSVsPos;
        
        % 위성 위치값(ECEF) ENU 좌표계 변환
        NST(k).DATA(:, COL_DATA_SVENU) = ecef2enu(NST(k).DATA(:, COL_DATA_SVXYZ), RefPos);
        
        % Azimuth, Elevation 각도 계산
        [NST(k).DATA(:, COL_DATA_AZ), NST(k).DATA(:, COL_DATA_EL)] = enu2azel(NST(k).DATA(:, COL_DATA_SVENU));
        
        % Mask Angle에 따른 위성 데이터 제거
        del_PRN = find(NST(k).DATA(:, COL_DATA_EL) < NST(k).CONF.MASK);
        if(~isempty(del_PRN)), NST(k).DATA(del_PRN, :) = []; end
    end
    
    % Integrity Monitoring : 현재 QM 일부만 적용(추후 여러 수신기(혹은 기준국)의 경우가 추가될 것으로 예상)
	IM_NST_01;
	
    % 항법 알고리즘 부분 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for k=1:NumOfReceiver
        % Lock Time 체크에 따른 데이터 제거 <- MQM 추가 후 제거
        del_PRN = find(NST(k).DATA(:, COL_DATA_L1_LockTime) < 100);
        if(~isempty(del_PRN)), NST(k).DATA(del_PRN, :) = []; end
        
        % C/N0 체크에 따른 위성 데이터 제거 <- SQM 추가 후 제거
        del_PRN = find(NST(k).DATA(:, COL_DATA_S1C) < 35);
        if(~isempty(del_PRN)), NST(k).DATA(del_PRN, :) = []; end
        
        % IM 테스트 결과 적용
%         del_PRN = find(NST(k).DATA(:, COL_DATA_IMFlag) ~= 0);
%         if(~isempty(del_PRN)), NST(k).DATA(del_PRN, :) = []; end
        
        % 스무딩 <- 1~2 에폭이 떨어진 경우에 대한 스무딩이 적용되어 있음
        if NPS.ReFLAGS(k) == 0
            [NST(k).DATA, preSmoothing{k}] = smoothing(NPS.GPSTIME, NPS.TIMESTEP, NST(k).DATA, preSmoothing{k});
        end
    end
    
    % 위성별 데이터 유무 확인과 공통 위성 데이터 생성 (<- 옵션: 모든 수신기 데이터가 있는 위성 데이터 선별)
    temp01 = NumOfReceiver + 1;                     % 위성별 수신기 데이터 수 + 1
    NPS.DATA_OX = zeros(CONST_GPS_PRNmax, temp01);  % 위성별 수신기 데이터 유무와 행위치 저장
    for k1=NumOfReceiver:-1:1                       % 1: User
        NST(k1).EPOCH.NoSV = size(NST(k1).DATA, 1);
        if NPS.ReFLAGS(k1) ~= 0, continue; end      % 현재 시간의 데이터가 없는 수신기는 건너뜀
        for k2=1:NST(k1).EPOCH.NoSV
            PRN = NST(k1).DATA(k2,COL_DATA_PRN);
            NPS.DATA_OX(PRN, k1) = k2;              % 데이터가 있는 경우 행위치 저장
            NPS.DATA_OX(PRN, temp01) = NPS.DATA_OX(PRN, temp01) + 1;% 데이터 수 계산
        end
    end
    
    NPS.PRNc = find(NPS.DATA_OX(:, temp01) == NumOfReceiver);   % 모든 수신기 데이터가 있는 위성 데이터 위치
    for k1=1:NumOfReceiver                          % 현재 시간의 데이터가 없는 수신기에 대한 고려는 추후 필요 시 수정
        NST(k1).DATAc = NST(k1).DATA(NPS.DATA_OX(NPS.PRNc, k1), :);
    end
    NPS.NoSVc = size(NST(1).DATAc, 1);              % 공통위성 데이터 관측 수 계산(1: 사용자)
    
    % 모드 결정(상황에 따른 모드 추가 예정)
    if NPS.NoSVc > 4
        NPS.MODE = MODE_Tachikoma;
    else
        NPS.MODE = 999;
    end
    
    % 모드에 따른 조합
    switch NPS.MODE
        case MODE_Tachikoma
            % Receiver
            NST(1).EPOCH.ENU = ecef2enu(NST(1).EPOCH.XYZB(1:3), RefPos);
            
            % CDGPS, RGPS, SD, NST
            CDGPS_RGPS_SD_NST;          % CDGPS 미지정수 실수 추정
            
            % CDGPS, RGPS, DD, NST
            
            
            % DGPS, LADGPS
            DGPS_LADGPS;
            
            % DGPS, RGPS, SD
            DGPS_RGPS;
            
            % StandAlone
            NST(1).XYZB_SA = olspos(NST(1).DATA(:, COL_DATA_C1C) - NST(1).DATA(:, COL_DATA_TropoCorr) - NST(1).DATA(:, COL_DATA_IonCorr), NST(1).DATA(:, COL_DATA_SVXYZ));
            NST(1).ENU_SA = ecef2enu(NST(1).XYZB_SA(1:3), RefPos);
%             NST(2).XYZB_SA = olspos(NST(2).DATA(:, COL_DATA_C1C), NST(2).DATA(:, COL_DATA_SVXYZ));
%             NST(2).ENU_SA = ecef2enu(NST(2).XYZB_SA(1:3), RefPos);
            
            % StandAlone + trop
%             NST(1).XYZB_PE = olspos(NST(1).DATA(:, COL_DATA_C1C) - NST(1).DATA(:, COL_DATA_TropoCorr), NST(1).DATA(:, COL_DATA_SVXYZ));
%             NST(1).ENU_PE = ecef2enu(NST(1).XYZB_PE(1:3), RefPos);
            NST(1).XYZB_PE = olspos(NST(1).DATA(:, COL_DATA_C2W) - NST(1).DATA(:, COL_DATA_TropoCorr) - NST(1).DATA(:, COL_DATA_IonCorr), NST(1).DATA(:, COL_DATA_SVXYZ));
            NST(1).ENU_PE = ecef2enu(NST(1).XYZB_PE(1:3), RefPos);
            
            % 위치 다항식 추정(4차)
%             NST(1).XYZB_PE = ;
%             NST(1).ENU_PE = ;
        case MODE_Sin
            error('Oops!');
        case MODE_Joe
            error('Oops!');
        case MODE_AE86
            error('Oops!');
        otherwise
            % 현재 데이터 유지
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % 결과 저장 <- 원하는 형태(변수 혹은 파일)로 개별적으로 작성
    % output();
    % 변수 저장 예
    zzz1(NPS.COUNT,:) = [NPS.GPSTIME, NST(1).EPOCH.ENU, NST(1).ENU_NSTSD, NST(1).ENU_LADGPS, NST(1).ENU_RGPSSD, NST(1).ENU_PE, NST(1).ENU_SA];
%     zzz1(NPS.COUNT,:) = [NPS.COUNT, NPS.GPSTIME, NST(1).EPOCH.ENU, NST(1).ENU_NSTSD, NST(1).ENU_LADGPS, NST(1).ENU_RGPSSD, NST(1).ENU_PE, NST(1).ENU_SA];
    
    zzz2(NPS.COUNT,:) = [NPS.GPSTIME, NPS.MODE, NPS.ReFLAGS(1), NPS.ReFLAGS(2), NPS.NoSVc];
    
    % 백업
    for k=1:NumOfReceiver
        if NPS.ReFLAGS(k) == 0                      % 현재 시간 데이터에 대한 백업
            if NST(k).IoB < NoB, NST(k).IoB = NST(k).IoB + 1;
            else NST(k).IoB = 1; end
            NST(k).BackupEPOCH{NST(k).IoB} = NST(k).EPOCH;
            NST(k).BackupDATA{NST(k).IoB} = NST(k).DATA;
        end
    end
    if NPS.IoB < NoB, NPS.IoB = NPS.IoB + 1;        % 백업
    else NPS.IoB = 1; end
    BackupNPS{NPS.IoB} = NPS;
    
    % 수동 종료
    if NPS.COUNT == EoE, fclose('all'); disp(['End...              ', num2str(NPS.COUNT)]); break; end
    
    % 데이터 읽음
    NPS.GPSTIME = NPS.GPSTIME + NPS.TIMESTEP;
    NPS.ReFLAGS = ones(1,NumOfReceiver);
    NPS.TIMEGAP = NaN(1,NumOfReceiver);
    for k=1:NumOfReceiver
        if (NST(k).EPOCH.GPSTIME < NPS.GPSTIME) && (FileEnd(k) == 0)    % 현재 시간 전의 데이터를 갖고 있으면, 다음 데이터 읽음
            read_RAW;
        end
        
        % 빠른 실행을 위한 읽는 부분 Matlab 저장 변수 mat 파일로의 저장(끝나는 시점에 대한 수정이 있는 경우는 이 함수 내용도 수정이 필요)
        if FlagSaveMat && (NST(k).CONF.MODEL == MODEL_DLV3_PP), save_mat_NovAtel; end
        
        if NST(k).EPOCH.GPSTIME == NPS.GPSTIME      % 읽은 데이터가 현재 시간 데이터인지 여부 체크
            NPS.ReFLAGS(k) = 0;                     % 0: OK, 1: fail, > 1: option <--- 일부 데이터 수신에 관한 것은 추후 추가
            NPS.TIMEGAP(k) = NST(k).EPOCH.GPSTIME - NST(k).BackupEPOCH{NST(k).IoB}.GPSTIME;
        end
%         if NPS.COUNT == 1200% || NPS.COUNT == 1300 || NPS.COUNT == 1400
%             NPS.ReFLAGS(k) = 1;
%         end
        
        % 궤도력 데이터 검증 및 배치
        % (궤도력 사용 및 백업: 현재는 같은 시간대의 데이터는 최근 데이터를 사용하며, 사용 데이터는 BackupEPH 1열에 저장하고, 기존 데이터는 2열에 저장)
        while ~isempty(NST(k).BufferEPH)            % 일반적인 2시간 단위 갱신을 가정한 것으로 그 외의 경우(예, 1시간 단위 갱신 등)를 고려할 경우는 수정이 필요
%             % 시간 변화(2시간)에 따른 인덱스 값 갱신
%             if floor(NPS.GPSTIME / (60*60*2)) ~= No2hours_S     % 2시간 단위 시간이 변화한(증가한) 경우
%                 % 인덱스 값 갱신
%                 disp(NPS.COUNT+1)
%                 disp(NPS.GPSTIME)
%                 disp(floor(NPS.GPSTIME / (60*60*2)))
%                 disp(NPS.GPSTIME / (60*60*2))
%                 disp(No2hours_S)
%                 if NPS.IoE ~= NoE, NPS.IoE = NPS.IoE + 1; else NPS.IoE = 1; end     % 현재 데이터 위치값
%                 No2hours_S = No2hours_S + 1;                                        % 기준 위치값
%                 
%                 % 마지막 Ephemeris 데이터 값 초기화
%                 temp02 = NPS.IoE + 2;                           % +1: 다음 시간대, +2: 가장 먼 시간대
%                 if temp02 > NoE, temp02 = temp02 - NoE; end     % 메모리 위치 보정
%                 NPS.EPH(:, temp02) = repmat(struct(initEPH), CONST_GPS_PRNmax, 1);
%             end
%             
%             % 현재 시간 기준 2시간 단위 카운터 수와 궤도력 시간 카운터 수 계산
%             No2hours_E = floor((NST(k).BufferEPH(1).GPSWeek*60*60*24*7 + NST(k).BufferEPH(1).TOE+60) / (60*60*2));  % TOE+60은 59분 28초, 44초의 경우에 대한 보정
%             
%             % 메모리 위치 계산(NPS.IoE: 현재 위치값)과 궤도력 데이터 검증 및 배치
%             temp03 = No2hours_E - No2hours_S;                   % 현재 시간대 Ephemeris 또는 다음 시간대 Ephemeris만 수신되므로 체크
%             if temp03 == 0 || temp03 == 1, temp03 = temp03 + NPS.IoE; else temp03 = 0; end
%             if temp03 > NoE, temp03 = temp03 - NoE; end         % 메모리 위치 보정
%             if (1 <= temp03) && (temp03 <= NoE)         % 초기 궤도력 데이터는 설정 범위 내의 데이터만 저장 (NoE = NPS.IoE + 1)
%                 if k==1                                 % 사용자 궤도력만 사용 <- 모든 기준국 포함 궤도력을 사용할 경우는 이 조건문 없앰
%                     if ~isempty(NPS.EPH(NST(k).BufferEPH(1).PRN, temp03).PRN)                       % 데이터가 존재할 때
%                         if NPS.EPH(NST(k).BufferEPH(1).PRN, temp03).TOE > NST(k).BufferEPH(1).TOE   % 완전 동일한 시간이 아니면서 59분 XX초인 경우(같은 시간대는 건너뜀) <- 이 부분은 반대의 경우가 될 수도 있음
%                             % 궤도력 데이터 검증 (초기화 중에 .DQMFlag 추가 필요)
% %                             DQM;
%                             
%                             % 궤도력 검증 부분이 추가될 경우, 이에 대한 조건문 필요
%                             NPS.EPH(NST(k).BufferEPH(1).PRN, temp03) = NST(k).BufferEPH(1);
%                             
%                             % 궤도력 데이터 백업
% %                             No2hours_Y = ;
% %                             No2hours_D = ;
% %                             No2hours_H = ;
% %                             BackupEPH{NST(k).BufferEPH(1).PRN}(, ) = ;
%                         end
%                     else    % 데이터가 존재하지 않는 경우
%                         % 궤도력 데이터 검증 (초기화 중에 .DQMFlag 추가 필요)
% %                         DQM;
%                         
%                         % 궤도력 검증 부분이 추가될 경우, 이에 대한 조건문 필요
%                         NPS.EPH(NST(k).BufferEPH(1).PRN, temp03) = NST(k).BufferEPH(1);
%                         
%                         % 궤도력 데이터 백업
% %                         No2hours_Y = ;
% %                         No2hours_D = ;
% %                         No2hours_H = ;
% %                         BackupEPH{NST(k).BufferEPH(1).PRN}(, ) = ;
%                     end
%                 end
%             end
%             
            % 처리된 데이터 제거
            NST(k).BufferEPH(1) = [];
        end
    end
    
    % 프로그램 종료(파일 종료 체크; 추후 다수의 기준국을 고려할 경우는 다시 작성 필요)
%     if sum(FileEnd), fclose('all'); disp(['End...              ', num2str(NPS.COUNT)]); break; end;
%     if FileEnd(1) || (sum(FileEnd(2:end)) == NumOfReceiver - 1), fclose('all'); disp(['End...              ', num2str(NPS.COUNT)]); break; end;
    % 사용자 파일이 끝나는 시점이 프로그램 끝나는 시점으로 설정
    if FileEnd(1), fclose('all'); disp(['End...              ', num2str(NPS.COUNT)]); break; end
    
    % Epoch 카운트
    NPS.COUNT = NPS.COUNT + 1;disp(['Processing...       ', num2str(NPS.COUNT), '  ', num2str(NPS.ReFLAGS(1)), '  ', num2str(NPS.ReFLAGS(2))]);
%     if rem(NPS.COUNT,10) == 0, disp(['Processing...       ', num2str(NPS.COUNT)]); end; % 10개 처리마다 진행 카운트 출력
    
    if NPS.COUNT == 1579
        SJY = 0;
    end
end

%% 결과 출력(그래프)
temp11 = ecef2enu(UsrPos, RefPos);

% temp_t = gps2utc([rem(floor(zzz1(:,1) ./ (60*60*24*7)), 1024), rem(zzz1(:,1), 60*60*24*7)], 0);
% temp = temp_t(:, 3)*24 + temp_t(:, 4) + temp_t(:, 5)/60 + temp_t(:, 6)/60/60;    % UTC 일시분초

% temp12 = 1:size(zzz1,1);
temp12 = 1*60*2+1:size(zzz1,1);
temp13 = temp12/60/2;

figure(1);
subplot(5,1,1);plot(temp13, zzz1(temp12,2) - temp11(1), '-');grid on;ylim([-2, 2]);
subplot(5,1,2);plot(temp13, zzz1(temp12,5) - temp11(1), '-');grid on;%ylim([-2, 2]);
subplot(5,1,3);plot(temp13, zzz1(temp12,8) - temp11(1), '-');grid on;ylim([-2, 2]);
subplot(5,1,4);plot(temp13, zzz1(temp12,11) - temp11(1), '-');grid on;ylim([-2, 2]);
subplot(5,1,5);plot(temp13, zzz1(temp12,17) - temp11(1), '-');grid on;ylim([-2, 2]);
hold on;plot(temp13, zzz1(temp12,14) - temp11(1), 'r-');grid on;ylim([-2, 2]);

figure(2);
subplot(5,1,1);plot(temp13, zzz1(temp12,3) - temp11(2), '-');grid on;ylim([-2, 2]);
subplot(5,1,2);plot(temp13, zzz1(temp12,6) - temp11(2), '-');grid on;%ylim([-2, 2]);
subplot(5,1,3);plot(temp13, zzz1(temp12,9) - temp11(2), '-');grid on;ylim([-2, 2]);
subplot(5,1,4);plot(temp13, zzz1(temp12,12) - temp11(2), '-');grid on;ylim([-2, 2]);
subplot(5,1,5);plot(temp13, zzz1(temp12,18) - temp11(2), '-');grid on;ylim([-5, 5]);
hold on;plot(temp13, zzz1(temp12,15) - temp11(2), 'r-');grid on;ylim([-2, 2]);

figure(3);
subplot(5,1,1);plot(temp13, zzz1(temp12,4) - temp11(3), '-');grid on;ylim([-5, 5]);
subplot(5,1,2);plot(temp13, zzz1(temp12,7) - temp11(3), '-');grid on;%ylim([-5, 5]);
subplot(5,1,3);plot(temp13, zzz1(temp12,10) - temp11(3), '-');grid on;ylim([-5, 5]);
subplot(5,1,4);plot(temp13, zzz1(temp12,13) - temp11(3), '-');grid on;ylim([-5, 5]);
subplot(5,1,5);plot(temp13, zzz1(temp12,19) - temp11(3), '-');grid on;ylim([-5, 5]);
hold on;plot(temp13, zzz1(temp12,16) - temp11(3), 'r-');grid on;ylim([-5, 5]);

figure(4);
subplot(4,1,1);plot(temp13, zzz1(temp12, 5) - temp11(1), '-');grid on;%ylim([-2, 2]);
subplot(4,1,2);plot(temp13, zzz1(temp12, 6) - temp11(2), '-');grid on;%ylim([-5, 5]);
subplot(4,1,3);plot(temp13, zzz1(temp12, 7) - temp11(3), '-');grid on;%ylim([-10, 10]);
subplot(4,1,4);plot(temp13, sqrt(zzz1(temp12, 5).^2 + zzz1(temp12, 6).^2 + zzz1(temp12, 7).^2) - sqrt(temp11(1)^2 + temp11(2)^2 + temp11(3)^2), '-');grid on;%ylim([-10, 10]);

figure(5);
subplot(4,1,1);plot(temp13, zzz2(temp12, 2), '.-');grid on;
subplot(4,1,2);plot(temp13, zzz2(temp12, 3), '.-');grid on;
subplot(4,1,3);plot(temp13, zzz2(temp12, 4), '.-');grid on;
subplot(4,1,4);plot(temp13, zzz2(temp12, 5), '.-');grid on;

figure(6);
subplot(4,1,1);plot(zzz2(:, 2), '.-');grid on;
subplot(4,1,2);plot(zzz2(:, 3), '.-');grid on;
subplot(4,1,3);plot(zzz2(:, 4), '.-');grid on;
subplot(4,1,4);plot(zzz2(:, 5), '.-');grid on;

clear temp??;

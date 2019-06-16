%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RTK (KARI, NST)                                %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% �ʱ�ȭ
clear all;
close all;
clc;

% ���� �ð� ����
NumOfReceiver = 2;      % ���ű� �� : ���� 2������ ����, 3 �̻��� init_variables.m���� ���� ������ �ʿ��ϸ�, �� ��츦 ����Ͽ� ���α׷� �Ͽ����� �߰����� ������ ���� �� ����
% EoE = 7200*2;                % ������ ����ŭ ����(0: ������ ������)
% EoE = 0;                % ������ ����ŭ ����(0: ������ ������)
EoE = 60*2*20;                % ������ ����ŭ ����(0: ������ ������)
EoF = 0;                % ���� �� üũ ���� �ʱ�ȭ
NoB = 10;               % ������ ��� ephoch ��(10 �̻�)
NoE = 12*3 + 2;         % Ephemeris ��� ������ ���� ��(����: 2�ð�, 3 �̻�) <- 2�ð� ���� �������� �� ���� ��츦 ����� ��쿡�� ������ �ʿ��� �� ����
                        % (+2�� �����ð��� +1�� �߰����� �� ���� +1)
NPS = struct; BackupNPS = cell(NoB, 1);
NST = repmat(struct, 1, NumOfReceiver);
preSmoothing = cell(1, NumOfReceiver);          % ������ ����� ���� ���
FileEnd = zeros(1, NumOfReceiver);

FilteringPeriod = 3*60;                         % ���͸� �ֱ� ���� (����: ��)

init_const;
init_col_labels;
init_variables;     % �ش� ���� �̸��� ���⼭ ����, ���� ���´� �̿ϼ����� ���� ���� ����

FlagSaveMat = 0;    % ���� ������ ���� �д� �κ� Matlab ���� ���� mat ���Ϸ��� ���� �÷���(1: ����)
                    % 1�� ������ ���, save_mat_NovAtel �Լ����� �������� ��� �� ������ �κ� ���� ���� �ʿ�
zzz0 = cell(1, NumOfReceiver);  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% �ʱ� ���� : ������ ����(�ʱ�ð� ����: �ɼ�), �ʱ� ��ġ ���
% �ʱ� ������ ����
EoE_temp = EoE; EoE = 0;    % �ʱ�ð� ���� ���������� ������ üũ ����(mat ���� ���忡 ���)
NPS.COUNT = 1;disp(['Init Processing...  ', num2str(NPS.COUNT)]);
temp01 = NaN(1,NumOfReceiver*2);
for k=1:NumOfReceiver
    read_RAW;
    
    temp01(k) = NST(k).EPOCH.GPSTIME;               % �α� �������� ó�� �ð�
    temp01(k+NumOfReceiver) = NST(k).CONF.STARTTIME;% ������ ó�� �ð�
end
NPS.GPSTIME = min(temp01);
temp02 = max(temp01);

for k=1:NumOfReceiver                               % ó�� ������ ���� �ð��� ����� �Ŀ� ����
    % ���� ������ ���� �д� �κ� Matlab ���� ���� mat ���Ϸ��� ����(������ ������ ���� ������ �ִ� ���� �� �Լ� ���뵵 ������ �ʿ�)
    if FlagSaveMat && (NST(k).CONF.MODEL == MODEL_DLV3_PP), save_mat_NovAtel; end
end

% ���ű⺰ �ð� ���� ���� ������ ����(<- �ð� ���� ���� ������ ó���� ����)
if NPS.GPSTIME == temp02                            % ó�� �����Ͱ� ���Ⱑ �Ǿ� �ִ� ���
    NPS.ReFLAGS = zeros(1,NumOfReceiver);
else
    while sum(NPS.ReFLAGS)      %%%%%%%%%% ���� ���ر��� ����ϴ� ��� ���� ���� ���� %%%%%%%%%%
        NPS.COUNT = NPS.COUNT + 1;disp(['Init Processing...  ', num2str(NPS.COUNT), '  ', num2str(NPS.ReFLAGS(1)), '  ', num2str(NPS.ReFLAGS(2))]);
        NPS.GPSTIME = NPS.GPSTIME + NPS.TIMESTEP;
        NPS.ReFLAGS = ones(1,NumOfReceiver);
        for k=1:NumOfReceiver
            if (NST(k).EPOCH.GPSTIME < temp02) && (NST(k).EPOCH.GPSTIME < NPS.GPSTIME) && (FileEnd(k) == 0)
                read_RAW;                           % ���� �����Ͱ� �����ð� ���̸�, ���� ������ ����
            end
            
            % ���� ������ ���� �д� �κ� Matlab ���� ���� mat ���Ϸ��� ����(������ ������ ���� ������ �ִ� ���� �� �Լ� ���뵵 ������ �ʿ�)
            if FlagSaveMat && (NST(k).CONF.MODEL == MODEL_DLV3_PP), save_mat_NovAtel; end
            
            if NST(k).EPOCH.GPSTIME > temp02        % �����ð��� �����Ͱ� ���� ��� �����ð� ����
                temp02 = NST(k).EPOCH.GPSTIME;
            elseif NST(k).EPOCH.GPSTIME == temp02   % �����ð��� ������ ���� üũ
                NPS.ReFLAGS(k) = 0;                 % 0: OK, 1: fail, > 1: option
            end
        end
%         [NPS.GPSTIME, NST(1).EPOCH.GPSTIME, NST(2).EPOCH.GPSTIME]
    end
end

% �ʱ� ��ġ ���
for k=1:NumOfReceiver
    NST(k).CONF.STARTTIME = NPS.GPSTIME;            % ���� �ð� ����
    
    % �˵��� ������ ���� �� ��ġ
    % (�˵��� ��� �� ���: ����� ���� �ð����� �����ʹ� �ֱ� �����͸� ����ϸ�, ��� �����ʹ� BackupEPH 1���� �����ϰ�, ���� �����ʹ� 2���� ����)
    while ~isempty(NST(k).BufferEPH)                % �Ϲ����� 2�ð� ���� ������ ������ ������ �� ���� ���(��, 1�ð� ���� ���� ��)�� ����� ���� ������ �ʿ�
%         % ���� �ð� ���� 2�ð� ���� ī���� ���� �˵��� �ð� ī���� �� ���
%         No2hours_S = floor(NPS.GPSTIME / (60*60*2));
%         No2hours_E = floor((NST(k).BufferEPH(1).GPSWeek*60*60*24*7 + NST(k).BufferEPH(1).TOE+60) / (60*60*2));          % TOE+60�� 59�� 28��, 44���� ��쿡 ���� ����
% %         No2hours_E = floor((NST(k).BufferEPH(1).GPSWeek*60*60*24*7 + NST(k).BufferEPH(1).TOE+60 + 60*60) / (60*60*2));  % TOE+60�� 59�� 28��, 44���� ��쿡 ���� ����, Ȧ�� �ð��뿡�� ���� ���(+1�ð����� ����, 1~3�ô� TOE 2�� ������ ���)
%         
%         % �޸� ��ġ ���(NPS.IoE: ���� ��ġ��)�� �˵��� ������ ���� �� ��ġ
%         temp03 = No2hours_E - No2hours_S + NPS.IoE;
%         if (1 <= temp03) && (temp03 <= NoE)         % �ʱ� �˵��� �����ʹ� ���� ���� ���� �����͸� ���� (NoE = NPS.IoE + 1)
%             if k==1                                 % ����� �˵��¸� ��� <- ��� ���ر� ���� �˵����� ����� ���� �� ���ǹ� ����
%                 if ~isempty(NPS.EPH(NST(k).BufferEPH(1).PRN, temp03).PRN)                       % �����Ͱ� ������ ��
%                     if NPS.EPH(NST(k).BufferEPH(1).PRN, temp03).TOE > NST(k).BufferEPH(1).TOE   % ���� ������ �ð��� �ƴϸ鼭 59�� XX���� ���(���� �ð���� �ǳʶ�) <- �� �κ��� �ݴ��� ��찡 �� ���� ����
%                         % �˵��� ������ ���� (�ʱ�ȭ �߿� .DQMFlag �߰� �ʿ�)
% %                         DQM;
%                         
%                         % �˵��� ���� �κ��� �߰��� ���, �̿� ���� ���ǹ� �ʿ�
%                         NPS.EPH(NST(k).BufferEPH(1).PRN, temp03) = NST(k).BufferEPH(1);
%                         
%                         % �˵��� ������ ���
% %                         No2hours_Y = ;
% %                         No2hours_D = ;
% %                         No2hours_H = ;
% %                         BackupEPH{NST(k).BufferEPH(1).PRN}(, ) = ;
%                     end
%                 else    % �����Ͱ� �������� �ʴ� ���
%                     % �˵��� ������ ���� (�ʱ�ȭ �߿� .DQMFlag �߰� �ʿ�)
% %                     DQM;
%                     
%                     % �˵��� ���� �κ��� �߰��� ���, �̿� ���� ���ǹ� �ʿ�
%                     NPS.EPH(NST(k).BufferEPH(1).PRN, temp03) = NST(k).BufferEPH(1);
%                     
%                     % �˵��� ������ ���
% %                     No2hours_Y = ;
% %                     No2hours_D = ;
% %                     No2hours_H = ;
% %                     BackupEPH{NST(k).BufferEPH(1).PRN}(, ) = ;
%                 end
%             end
%         end
%         
        % ó���� ������ ����
        NST(k).BufferEPH(1) = [];
    end
    
    % ���� ��ġ ��� : ���� ���� �Լ��� �������� �ʴ� ���, ���ű⿡�� ���� ���� ��ġ���� ����
%     calSVsPos;
    
    % ��ġ ���(StandAlone)
    if k==1     % user
%         temp05 = [-3119513.74099720, 4086862.18153458, 3761997.67677431];   % ��Ȯ�� ������ ���� ����
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
RefPos = NST(2).EPOCH.XYZB(1:3);                                    % ù ��° ���ر��� ���������� ����
% UsrPos = temp05(1:3); %%%%%%%%%%%%%%%%%%%%%%%%%%
% RefPos = temp05(1:3); %%%%%%%%%%%%%%%%%%%%%%%%%%

% KARI, KAU
% UsrPos = [-3035387.92654911, 4047988.19623592, 3870472.94625895];   % ��Ȯ�� ������ ���� ����
% RefPos = [-3119514.04733591, 4086861.04481042, 3761998.82500128];

% KARI(20080709 ~ 20080710)
% UsrPos = [-3119513.74099720, 4086862.18153458, 3761997.67677431];   % ��Ȯ�� ������ ���� ����
UsrPos = [-3119516.637174607, 4086863.709305724, 3762000.145357828];    % UsrPos: CDGPS ����ġ�� ������� ����
RefPos = [-3119514.34400035, 4086861.44802314, 3761998.01570046];
% NST(1).XYZB_NSTSD = [UsrPos, 0];
% NST(2).XYZB_NSTSD = [RefPos, 0];

% KARI(20080812 ~ 20080815)  <- �߸� ���Ѱ����� ������
% UsrPos = [-3119514.19312775, 4086860.98983432, 3761998.76059499];   % ��Ȯ�� ������ ���� ����
% RefPos = [-3119549.37207833, 4086836.52864946, 3761999.60932773];

for k=1:NumOfReceiver                               % ��ǥ ��ȯ
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

% ���͸� ���� �ʱ�ȭ
FilteringTime_SD = NPS.GPSTIME - FilteringPeriod;   % �ʱ� ������ ���� ����

%% 
EoE = EoE_temp;clear EoE_temp;
NPS.COUNT = 1;disp(['Processing...       ', num2str(NPS.COUNT), '  ', num2str(NPS.ReFLAGS(1)), '  ', num2str(NPS.ReFLAGS(2))]);
while 1
    for k=1:NumOfReceiver
        % GPS�� ���� ������ ����
        del_PRN = find(NST(k).DATA(:, COL_DATA_PRN) > CONST_GPS_PRNmax);
        if(~isempty(del_PRN)), NST(k).DATA(del_PRN, :) = []; end
%         del_PRN = find(NST(k).DATA(:, COL_DATA_PRN) == 22);
%         if(~isempty(del_PRN)), NST(k).DATA(del_PRN, :) = []; end
        
        % PRN�� ������ ����
        NST(k).DATA = sortrows(NST(k).DATA, COL_DATA_PRN);
        
        % ���� ��ġ ��� : ���� ���� �Լ��� �������� �ʴ� ���, ���ű⿡�� ���� ���� ��ġ���� ����
%         calSVsPos;
        
        % ���� ��ġ��(ECEF) ENU ��ǥ�� ��ȯ
        NST(k).DATA(:, COL_DATA_SVENU) = ecef2enu(NST(k).DATA(:, COL_DATA_SVXYZ), RefPos);
        
        % Azimuth, Elevation ���� ���
        [NST(k).DATA(:, COL_DATA_AZ), NST(k).DATA(:, COL_DATA_EL)] = enu2azel(NST(k).DATA(:, COL_DATA_SVENU));
        
        % Mask Angle�� ���� ���� ������ ����
        del_PRN = find(NST(k).DATA(:, COL_DATA_EL) < NST(k).CONF.MASK);
        if(~isempty(del_PRN)), NST(k).DATA(del_PRN, :) = []; end
    end
    
    % Integrity Monitoring : ���� QM �Ϻθ� ����(���� ���� ���ű�(Ȥ�� ���ر�)�� ��찡 �߰��� ������ ����)
	IM_NST_01;
	
    % �׹� �˰��� �κ� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for k=1:NumOfReceiver
        % Lock Time üũ�� ���� ������ ���� <- MQM �߰� �� ����
        del_PRN = find(NST(k).DATA(:, COL_DATA_L1_LockTime) < 100);
        if(~isempty(del_PRN)), NST(k).DATA(del_PRN, :) = []; end
        
        % C/N0 üũ�� ���� ���� ������ ���� <- SQM �߰� �� ����
        del_PRN = find(NST(k).DATA(:, COL_DATA_S1C) < 35);
        if(~isempty(del_PRN)), NST(k).DATA(del_PRN, :) = []; end
        
        % IM �׽�Ʈ ��� ����
%         del_PRN = find(NST(k).DATA(:, COL_DATA_IMFlag) ~= 0);
%         if(~isempty(del_PRN)), NST(k).DATA(del_PRN, :) = []; end
        
        % ������ <- 1~2 ������ ������ ��쿡 ���� �������� ����Ǿ� ����
        if NPS.ReFLAGS(k) == 0
            [NST(k).DATA, preSmoothing{k}] = smoothing(NPS.GPSTIME, NPS.TIMESTEP, NST(k).DATA, preSmoothing{k});
        end
    end
    
    % ������ ������ ���� Ȯ�ΰ� ���� ���� ������ ���� (<- �ɼ�: ��� ���ű� �����Ͱ� �ִ� ���� ������ ����)
    temp01 = NumOfReceiver + 1;                     % ������ ���ű� ������ �� + 1
    NPS.DATA_OX = zeros(CONST_GPS_PRNmax, temp01);  % ������ ���ű� ������ ������ ����ġ ����
    for k1=NumOfReceiver:-1:1                       % 1: User
        NST(k1).EPOCH.NoSV = size(NST(k1).DATA, 1);
        if NPS.ReFLAGS(k1) ~= 0, continue; end      % ���� �ð��� �����Ͱ� ���� ���ű�� �ǳʶ�
        for k2=1:NST(k1).EPOCH.NoSV
            PRN = NST(k1).DATA(k2,COL_DATA_PRN);
            NPS.DATA_OX(PRN, k1) = k2;              % �����Ͱ� �ִ� ��� ����ġ ����
            NPS.DATA_OX(PRN, temp01) = NPS.DATA_OX(PRN, temp01) + 1;% ������ �� ���
        end
    end
    
    NPS.PRNc = find(NPS.DATA_OX(:, temp01) == NumOfReceiver);   % ��� ���ű� �����Ͱ� �ִ� ���� ������ ��ġ
    for k1=1:NumOfReceiver                          % ���� �ð��� �����Ͱ� ���� ���ű⿡ ���� ����� ���� �ʿ� �� ����
        NST(k1).DATAc = NST(k1).DATA(NPS.DATA_OX(NPS.PRNc, k1), :);
    end
    NPS.NoSVc = size(NST(1).DATAc, 1);              % �������� ������ ���� �� ���(1: �����)
    
    % ��� ����(��Ȳ�� ���� ��� �߰� ����)
    if NPS.NoSVc > 4
        NPS.MODE = MODE_Tachikoma;
    else
        NPS.MODE = 999;
    end
    
    % ��忡 ���� ����
    switch NPS.MODE
        case MODE_Tachikoma
            % Receiver
            NST(1).EPOCH.ENU = ecef2enu(NST(1).EPOCH.XYZB(1:3), RefPos);
            
            % CDGPS, RGPS, SD, NST
            CDGPS_RGPS_SD_NST;          % CDGPS �������� �Ǽ� ����
            
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
            
            % ��ġ ���׽� ����(4��)
%             NST(1).XYZB_PE = ;
%             NST(1).ENU_PE = ;
        case MODE_Sin
            error('Oops!');
        case MODE_Joe
            error('Oops!');
        case MODE_AE86
            error('Oops!');
        otherwise
            % ���� ������ ����
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % ��� ���� <- ���ϴ� ����(���� Ȥ�� ����)�� ���������� �ۼ�
    % output();
    % ���� ���� ��
    zzz1(NPS.COUNT,:) = [NPS.GPSTIME, NST(1).EPOCH.ENU, NST(1).ENU_NSTSD, NST(1).ENU_LADGPS, NST(1).ENU_RGPSSD, NST(1).ENU_PE, NST(1).ENU_SA];
%     zzz1(NPS.COUNT,:) = [NPS.COUNT, NPS.GPSTIME, NST(1).EPOCH.ENU, NST(1).ENU_NSTSD, NST(1).ENU_LADGPS, NST(1).ENU_RGPSSD, NST(1).ENU_PE, NST(1).ENU_SA];
    
    zzz2(NPS.COUNT,:) = [NPS.GPSTIME, NPS.MODE, NPS.ReFLAGS(1), NPS.ReFLAGS(2), NPS.NoSVc];
    
    % ���
    for k=1:NumOfReceiver
        if NPS.ReFLAGS(k) == 0                      % ���� �ð� �����Ϳ� ���� ���
            if NST(k).IoB < NoB, NST(k).IoB = NST(k).IoB + 1;
            else NST(k).IoB = 1; end
            NST(k).BackupEPOCH{NST(k).IoB} = NST(k).EPOCH;
            NST(k).BackupDATA{NST(k).IoB} = NST(k).DATA;
        end
    end
    if NPS.IoB < NoB, NPS.IoB = NPS.IoB + 1;        % ���
    else NPS.IoB = 1; end
    BackupNPS{NPS.IoB} = NPS;
    
    % ���� ����
    if NPS.COUNT == EoE, fclose('all'); disp(['End...              ', num2str(NPS.COUNT)]); break; end
    
    % ������ ����
    NPS.GPSTIME = NPS.GPSTIME + NPS.TIMESTEP;
    NPS.ReFLAGS = ones(1,NumOfReceiver);
    NPS.TIMEGAP = NaN(1,NumOfReceiver);
    for k=1:NumOfReceiver
        if (NST(k).EPOCH.GPSTIME < NPS.GPSTIME) && (FileEnd(k) == 0)    % ���� �ð� ���� �����͸� ���� ������, ���� ������ ����
            read_RAW;
        end
        
        % ���� ������ ���� �д� �κ� Matlab ���� ���� mat ���Ϸ��� ����(������ ������ ���� ������ �ִ� ���� �� �Լ� ���뵵 ������ �ʿ�)
        if FlagSaveMat && (NST(k).CONF.MODEL == MODEL_DLV3_PP), save_mat_NovAtel; end
        
        if NST(k).EPOCH.GPSTIME == NPS.GPSTIME      % ���� �����Ͱ� ���� �ð� ���������� ���� üũ
            NPS.ReFLAGS(k) = 0;                     % 0: OK, 1: fail, > 1: option <--- �Ϻ� ������ ���ſ� ���� ���� ���� �߰�
            NPS.TIMEGAP(k) = NST(k).EPOCH.GPSTIME - NST(k).BackupEPOCH{NST(k).IoB}.GPSTIME;
        end
%         if NPS.COUNT == 1200% || NPS.COUNT == 1300 || NPS.COUNT == 1400
%             NPS.ReFLAGS(k) = 1;
%         end
        
        % �˵��� ������ ���� �� ��ġ
        % (�˵��� ��� �� ���: ����� ���� �ð����� �����ʹ� �ֱ� �����͸� ����ϸ�, ��� �����ʹ� BackupEPH 1���� �����ϰ�, ���� �����ʹ� 2���� ����)
        while ~isempty(NST(k).BufferEPH)            % �Ϲ����� 2�ð� ���� ������ ������ ������ �� ���� ���(��, 1�ð� ���� ���� ��)�� ����� ���� ������ �ʿ�
%             % �ð� ��ȭ(2�ð�)�� ���� �ε��� �� ����
%             if floor(NPS.GPSTIME / (60*60*2)) ~= No2hours_S     % 2�ð� ���� �ð��� ��ȭ��(������) ���
%                 % �ε��� �� ����
%                 disp(NPS.COUNT+1)
%                 disp(NPS.GPSTIME)
%                 disp(floor(NPS.GPSTIME / (60*60*2)))
%                 disp(NPS.GPSTIME / (60*60*2))
%                 disp(No2hours_S)
%                 if NPS.IoE ~= NoE, NPS.IoE = NPS.IoE + 1; else NPS.IoE = 1; end     % ���� ������ ��ġ��
%                 No2hours_S = No2hours_S + 1;                                        % ���� ��ġ��
%                 
%                 % ������ Ephemeris ������ �� �ʱ�ȭ
%                 temp02 = NPS.IoE + 2;                           % +1: ���� �ð���, +2: ���� �� �ð���
%                 if temp02 > NoE, temp02 = temp02 - NoE; end     % �޸� ��ġ ����
%                 NPS.EPH(:, temp02) = repmat(struct(initEPH), CONST_GPS_PRNmax, 1);
%             end
%             
%             % ���� �ð� ���� 2�ð� ���� ī���� ���� �˵��� �ð� ī���� �� ���
%             No2hours_E = floor((NST(k).BufferEPH(1).GPSWeek*60*60*24*7 + NST(k).BufferEPH(1).TOE+60) / (60*60*2));  % TOE+60�� 59�� 28��, 44���� ��쿡 ���� ����
%             
%             % �޸� ��ġ ���(NPS.IoE: ���� ��ġ��)�� �˵��� ������ ���� �� ��ġ
%             temp03 = No2hours_E - No2hours_S;                   % ���� �ð��� Ephemeris �Ǵ� ���� �ð��� Ephemeris�� ���ŵǹǷ� üũ
%             if temp03 == 0 || temp03 == 1, temp03 = temp03 + NPS.IoE; else temp03 = 0; end
%             if temp03 > NoE, temp03 = temp03 - NoE; end         % �޸� ��ġ ����
%             if (1 <= temp03) && (temp03 <= NoE)         % �ʱ� �˵��� �����ʹ� ���� ���� ���� �����͸� ���� (NoE = NPS.IoE + 1)
%                 if k==1                                 % ����� �˵��¸� ��� <- ��� ���ر� ���� �˵����� ����� ���� �� ���ǹ� ����
%                     if ~isempty(NPS.EPH(NST(k).BufferEPH(1).PRN, temp03).PRN)                       % �����Ͱ� ������ ��
%                         if NPS.EPH(NST(k).BufferEPH(1).PRN, temp03).TOE > NST(k).BufferEPH(1).TOE   % ���� ������ �ð��� �ƴϸ鼭 59�� XX���� ���(���� �ð���� �ǳʶ�) <- �� �κ��� �ݴ��� ��찡 �� ���� ����
%                             % �˵��� ������ ���� (�ʱ�ȭ �߿� .DQMFlag �߰� �ʿ�)
% %                             DQM;
%                             
%                             % �˵��� ���� �κ��� �߰��� ���, �̿� ���� ���ǹ� �ʿ�
%                             NPS.EPH(NST(k).BufferEPH(1).PRN, temp03) = NST(k).BufferEPH(1);
%                             
%                             % �˵��� ������ ���
% %                             No2hours_Y = ;
% %                             No2hours_D = ;
% %                             No2hours_H = ;
% %                             BackupEPH{NST(k).BufferEPH(1).PRN}(, ) = ;
%                         end
%                     else    % �����Ͱ� �������� �ʴ� ���
%                         % �˵��� ������ ���� (�ʱ�ȭ �߿� .DQMFlag �߰� �ʿ�)
% %                         DQM;
%                         
%                         % �˵��� ���� �κ��� �߰��� ���, �̿� ���� ���ǹ� �ʿ�
%                         NPS.EPH(NST(k).BufferEPH(1).PRN, temp03) = NST(k).BufferEPH(1);
%                         
%                         % �˵��� ������ ���
% %                         No2hours_Y = ;
% %                         No2hours_D = ;
% %                         No2hours_H = ;
% %                         BackupEPH{NST(k).BufferEPH(1).PRN}(, ) = ;
%                     end
%                 end
%             end
%             
            % ó���� ������ ����
            NST(k).BufferEPH(1) = [];
        end
    end
    
    % ���α׷� ����(���� ���� üũ; ���� �ټ��� ���ر��� ����� ���� �ٽ� �ۼ� �ʿ�)
%     if sum(FileEnd), fclose('all'); disp(['End...              ', num2str(NPS.COUNT)]); break; end;
%     if FileEnd(1) || (sum(FileEnd(2:end)) == NumOfReceiver - 1), fclose('all'); disp(['End...              ', num2str(NPS.COUNT)]); break; end;
    % ����� ������ ������ ������ ���α׷� ������ �������� ����
    if FileEnd(1), fclose('all'); disp(['End...              ', num2str(NPS.COUNT)]); break; end
    
    % Epoch ī��Ʈ
    NPS.COUNT = NPS.COUNT + 1;disp(['Processing...       ', num2str(NPS.COUNT), '  ', num2str(NPS.ReFLAGS(1)), '  ', num2str(NPS.ReFLAGS(2))]);
%     if rem(NPS.COUNT,10) == 0, disp(['Processing...       ', num2str(NPS.COUNT)]); end; % 10�� ó������ ���� ī��Ʈ ���
    
    if NPS.COUNT == 1579
        SJY = 0;
    end
end

%% ��� ���(�׷���)
temp11 = ecef2enu(UsrPos, RefPos);

% temp_t = gps2utc([rem(floor(zzz1(:,1) ./ (60*60*24*7)), 1024), rem(zzz1(:,1), 60*60*24*7)], 0);
% temp = temp_t(:, 3)*24 + temp_t(:, 4) + temp_t(:, 5)/60 + temp_t(:, 6)/60/60;    % UTC �Ͻú���

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

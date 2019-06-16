%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CDGPS (RGPS, SD, NST)                          %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 고도각에 따른 분산값 계산
temp_I = eye(NPS.NoSVc);        % Identity matrix
var_C1C_SD = temp_I;
var_L1C_SD = temp_I;
for k=1:NPS.NoSVc               % 추후 앙각에 따른 값으로 대체
    var_C1C_SD(k, k) = 1^2;
    var_L1C_SD(k, k) = 0.01^2;
end

% 필터링 판별(필터 주기 및 위성 변화 확인)
[FilteringTime_SD, FilteringFlag] = decide_filtering(NPS, BackupNPS, FilteringTime_SD, FilteringPeriod);

% 필터링
if FilteringFlag == 1
    % 위성 데이터 변화에 따른 미지정수 재배열
    [Nhat_SD, N0_SD, delNhat_SD, P_SD] = rearrangeAmbiguity_SD(N0_SD, delNhat_SD, P_SD, NPS, BackupNPS, NST(1).DATAc, NST(2).DATAc, var_C1C_SD);
%     N0_SD = N0_SD + delNhat_SD; delNhat_SD = delNhat_SD * 0;
    % SD 측정치와 H 계산
%     [delZ, H_SD] = hSDmat(NST(1).DATAc, NST(2).DATAc, NST(1).ENU_NSTSD, NST(2).ENU_NSTSD, ClockBias_SD, Nhat_SD, NPS.NoSVc);
    [delZ, H_SD] = hSDmat(NST(1).DATAc, NST(2).DATAc, NST(1).ENU_NSTSD, NST(2).ENU_NSTSD, ClockBias_SD, N0_SD, NPS.NoSVc);
	
    % Carrier Redundancy
	L_H = null(H_SD')';                         % Left Null Space
	
	delZ = L_H*delZ;                            % Eliminating Obserbation Term
	H = L_H;
	R = L_H*var_L1C_SD*L_H';
	
    K = P_SD*H'*inv(H*P_SD*H' + R);             % Integer Measurement Update
    delNhat_SD = delNhat_SD + K*(delZ - H*delNhat_SD);
    P_SD = (temp_I - K*H)*P_SD;
    
    % Code against Carrier Average
	Z = (NST(1).DATAc(:, COL_DATA_L1C) - NST(2).DATAc(:, COL_DATA_L1C)) - (NST(1).DATAc(:, COL_DATA_C1C) - NST(2).DATAc(:, COL_DATA_C1C));
%     Z = (NST(1).DATAc(:, COL_DATA_L1C) - NST(2).DATAc(:, COL_DATA_L1C)) - (NST(1).DATAc(:, COL_DATA_C1Cs) - NST(2).DATAc(:, COL_DATA_C1Cs));
	delZ = Z - Nhat_SD;
	H = temp_I;
	R = var_L1C_SD + var_C1C_SD;
	
    K = P_SD*H'*inv(H*P_SD*H' + R);             % Integer Measurement Update
    delNhat_SD = delNhat_SD + K*(delZ - H*delNhat_SD);
    P_SD = (temp_I - K*H)*P_SD;
    
    Nhat_SD = N0_SD + delNhat_SD;
%     Nhat_SD = round((Nhat_SD + delNhat)/CONST_LAMBDA1)*CONST_LAMBDA1;
    
    % Time Update
    
    
    % Lamda method
    Nhat_SD_fixed = lambda2(Nhat_SD, P_SD);
    disp([NPS.PRNc, Nhat_SD_fixed, Nhat_SD]);
    temp = NaN(32,1);
    if NPS.COUNT == 1
        zzz_count = 1;
        zzz5 = temp;zzz6 = temp;zzz7 = temp;
    else
        zzz_count = zzz_count + 1;
        zzz5 = [zzz5, temp];zzz6 = [zzz6, temp];zzz7 = [zzz7, temp];
    end
    for k=1:NPS.NoSVc
        zzz5(NPS.PRNc(k), zzz_count) = Nhat_SD_fixed(k, 1);
        zzz6(NPS.PRNc(k), zzz_count) = Nhat_SD_fixed(k, 2);
        zzz7(NPS.PRNc(k), zzz_count) = Nhat_SD(k, 1);
    end
    
    % 미지정수 검증
    
end

% 위치 추정
% Re = inv(var_L1C_SD + P_SD); dx = 1;
Re = inv(var_L1C_SD); dx = 1;
while (norm(dx) > 0.0001)
    % SD 측정치와 H 계산
%     [delZ, H_SD] = hSDmat(NST(1).DATAc, NST(2).DATAc, NST(1).ENU_NSTSD, NST(2).ENU_NSTSD, ClockBias_SD, Nhat_SD, NPS.NoSVc);
    [delZ, H_SD] = hSDmat(NST(1).DATAc, NST(2).DATAc, NST(1).ENU_NSTSD, NST(2).ENU_NSTSD, ClockBias_SD, Nhat_SD_fixed(:, 1), NPS.NoSVc);
	
    dx = inv(H_SD'*Re*H_SD)*H_SD'*Re*delZ;
	
    NST(1).ENU_NSTSD = NST(1).ENU_NSTSD + dx(1:3)';
	ClockBias_SD = ClockBias_SD + dx(4);
end

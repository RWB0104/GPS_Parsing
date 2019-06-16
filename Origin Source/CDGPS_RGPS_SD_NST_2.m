%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CDGPS (RGPS, SD, NST)                          %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ������ ���� �л갪 ���
temp_I = eye(NPS.NoSVc);        % Identity matrix
var_C1C_SD = temp_I;
var_L1C_SD = temp_I;
for k=1:NPS.NoSVc               % ���� �Ӱ��� ���� ������ ��ü
    var_C1C_SD(k, k) = 1^2;
    var_L1C_SD(k, k) = 0.01^2;
end

% ���͸� �Ǻ�(���� �ֱ� �� ���� ��ȭ Ȯ��)
[FilteringTime_SD, FilteringFlag] = decide_filtering(NPS, BackupNPS, FilteringTime_SD, FilteringPeriod);

% ���͸�
if FilteringFlag == 1
	delNhat = zeros(NPS.NoSVc, 1);
	
    % ���� ������ ��ȭ�� ���� �������� ��迭
    [Nhat_SD, P_SD] = rearrangeAmbiguity(Nhat_SD, P_SD, NPS, BackupNPS, NST(1).DATAc, NST(2).DATAc, var_C1C_SD);
    
    % SD ����ġ�� H ���
    [delZ, H_SD] = hSDmat(NST(1).DATAc, NST(2).DATAc, NST(1).ENU_NSTSD, NST(2).ENU_NSTSD, ClockBias_SD, Nhat_SD, NPS.NoSVc);
	
    % Carrier Redundancy
	L_H = null(H_SD')';                         % Left Null Space
	
	delZ = L_H*delZ;                            % Eliminating Obserbation Term
	H = L_H;
	R = L_H*var_L1C_SD*L_H';
	
    K = P_SD*H'*inv(H*P_SD*H' + R);             % Integer Measurement Update
    delNhat = delNhat + K*(delZ - H*delNhat);
    P_SD = (temp_I - K*H)*P_SD;
    
    % Code against Carrier Average
	Z = (NST(1).DATAc(:, COL_DATA_L1C) - NST(2).DATAc(:, COL_DATA_L1C)) - (NST(1).DATAc(:, COL_DATA_C1C) - NST(2).DATAc(:, COL_DATA_C1C));
%     Z = (NST(1).DATAc(:, COL_DATA_L1C) - NST(2).DATAc(:, COL_DATA_L1C)) - (NST(1).DATAc(:, COL_DATA_C1Cs) - NST(2).DATAc(:, COL_DATA_C1Cs));
	delZ = Z - Nhat_SD;
	H = temp_I;
	R = var_L1C_SD + var_C1C_SD;
	
    K = P_SD*H'*inv(H*P_SD*H' + R);             % Integer Measurement Update
    delNhat = delNhat + K*(delZ - H*delNhat);
    P_SD = (temp_I - K*H)*P_SD;
    
    Nhat_SD = Nhat_SD + delNhat;
%     Nhat_SD = round((Nhat_SD + delNhat)/CONST_LAMBDA1)*CONST_LAMBDA1;
    
    % Time Update
    
    
    % Lamda method
%     if fixedAmbiguityFlag ~= 1
        Nhat_SD_fixed = lambda2(Nhat_SD, P_SD);
        disp([NPS.PRNc, Nhat_SD_fixed, Nhat_SD]);
        temp = NaN(32,1);
        if zzz_count == 0
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
%     end
    
    % �������� ����
%     zzz8 = zzz8 + 1;
%     if zzz8 >= 6
%         fixedAmbiguityFlag = 1;
%     end
end

% ��ġ ����
if fixedAmbiguityFlag == 1
    Re = inv(var_L1C_SD); dx = 1;
    while (norm(dx) > 0.0001)
        % SD ����ġ�� H ���
        [delZ, H_SD] = hSDmat(NST(1).DATAc, NST(2).DATAc, NST(1).ENU_NSTSD, NST(2).ENU_NSTSD, ClockBias_SD, Nhat_SD_fixed(:, 1), NPS.NoSVc);
    
        dx = inv(H_SD'*Re*H_SD)*H_SD'*Re*delZ;
    
        NST(1).ENU_NSTSD = NST(1).ENU_NSTSD + dx(1:3)';
    	ClockBias_SD = ClockBias_SD + dx(4);
    end
else
    Re = inv(var_L1C_SD + P_SD); dx = 1;
    while (norm(dx) > 0.0001)
        % SD ����ġ�� H ���
        [delZ, H_SD] = hSDmat(NST(1).DATAc, NST(2).DATAc, NST(1).ENU_NSTSD, NST(2).ENU_NSTSD, ClockBias_SD, Nhat_SD, NPS.NoSVc);
    
        dx = inv(H_SD'*Re*H_SD)*H_SD'*Re*delZ;
    
        NST(1).ENU_NSTSD = NST(1).ENU_NSTSD + dx(1:3)';
    	ClockBias_SD = ClockBias_SD + dx(4);
    end
end
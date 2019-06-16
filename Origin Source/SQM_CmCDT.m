function [Flags, QMData] = SQM_CmCDT(QMData, QMThresholds, PRN, NoSV, TimeStep)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SQM: Code-Carrier Divergence Test              %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by SJY                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global CONST_Tau_d CONST_QM_MaskAngle CONST_QM_PolyOrder
global COL_QM_CmCD
global COL_QM_DATA_C1C COL_QM_DATA_preC1C COL_QM_DATA_L1C COL_QM_DATA_preL1C COL_QM_DATA_EL 
global COL_QM_DATA_CmCD COL_QM_DATA_preCmCD
global COL_QM_Th_mean COL_QM_Th_coefficient COL_QM_Th_MAXEL

Flags = zeros(NoSV, 1);

% Code-Carrier Divergence Test
for k1=1:NoSV
    % 계산에 필요한 데이터 유무 체크 결과에 따른 테스트
    temp = isnan(QMData(PRN(k1), COL_QM_DATA_C1C)) + isnan(QMData(PRN(k1), COL_QM_DATA_L1C)) + ...
           isnan(QMData(PRN(k1), COL_QM_DATA_preC1C)) + isnan(QMData(PRN(k1), COL_QM_DATA_preL1C)) + ...
           isnan(QMData(PRN(k1), COL_QM_DATA_preCmCD));
    
    if temp == 0    % 계산에 필요한 데이터가 있는 경우
        % Code-Carrier Divergence 계산
        dz = (QMData(PRN(k1), COL_QM_DATA_C1C) - QMData(PRN(k1), COL_QM_DATA_L1C)) - (QMData(PRN(k1), COL_QM_DATA_preC1C) - QMData(PRN(k1), COL_QM_DATA_preL1C));
        QMData(PRN(k1), COL_QM_DATA_CmCD) = ((CONST_Tau_d - TimeStep)/CONST_Tau_d)*QMData(PRN(k1), COL_QM_DATA_preCmCD) + (1/CONST_Tau_d)*dz;
        
        % Threshold 계산
        el = QMData(PRN(k1), COL_QM_DATA_EL)*180/pi;   % unit: degree
        if el < CONST_QM_MaskAngle, el = CONST_QM_MaskAngle; end
        if el > QMThresholds{1,COL_QM_CmCD}(1, COL_QM_Th_MAXEL), el = QMThresholds{1,COL_QM_CmCD}(1, COL_QM_Th_MAXEL); end
        
        threshold_temp1 = QMThresholds{1,COL_QM_CmCD}(1, COL_QM_Th_mean);
        threshold_temp2 = QMThresholds{1,COL_QM_CmCD}(1, COL_QM_Th_coefficient(CONST_QM_PolyOrder+1));
        for k2 = 1:CONST_QM_PolyOrder
            threshold_temp2 = threshold_temp2 + (QMThresholds{1,COL_QM_CmCD}(PRN(k1), COL_QM_Th_coefficient(k2))) * el^(CONST_QM_PolyOrder+1-k2);
        end
        threshold_high = threshold_temp1 + threshold_temp2;
        threshold_low = threshold_temp1 - threshold_temp2;
        
        % 테스트
        if (QMData(PRN(k1), COL_QM_DATA_CmCD) > threshold_high) || (QMData(PRN(k1), COL_QM_DATA_CmCD) < threshold_low)
            Flags(k1, 1) = 1;
        end
    else            % 계산에 필요한 데이터가 없는 경우
        % Code-Carrier Divergence 계산(= 0)
        QMData(PRN(k1), COL_QM_DATA_CmCD) = 0;
        
        % 테스트: 플래그 1(이상 신호로 결정)
        Flags(k1, 1) = 1;
    end
end

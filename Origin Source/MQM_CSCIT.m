function [Flags, QMData] = MQM_CSCIT(QMData, QMThresholds, PRN, NoSV, TimeStep)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MQM: Carrier-Smoothed Code(CSC) Innovation Test%
%                                                %
% Version: 1.0_20080901                          %
% Programmed by SJY                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global CONST_Tau_d CONST_QM_MaskAngle CONST_QM_PolyOrder
global COL_QM_CSCI
global COL_QM_DATA_C1C COL_QM_DATA_preC1Cs COL_QM_DATA_preC1CsCount ...
       COL_QM_DATA_L1C COL_QM_DATA_preL1C COL_QM_DATA_EL 
global COL_QM_DATA_CSCI
global COL_QM_Th_mean COL_QM_Th_coefficient COL_QM_Th_MAXEL

Ns_max = CONST_Tau_d / TimeStep;
Flags = zeros(NoSV, 1);

% Carrier-Smoothed Code(CSC) Innovation Test
for k1=1:NoSV
    % 계산에 필요한 데이터 유무 체크 결과에 따른 테스트
    temp = isnan(QMData(PRN(k1), COL_QM_DATA_C1C)) + isnan(QMData(PRN(k1), COL_QM_DATA_preC1Cs)) + ...
           isnan(QMData(PRN(k1), COL_QM_DATA_L1C)) + isnan(QMData(PRN(k1), COL_QM_DATA_preL1C));
%     if QMData(PRN(k1), COL_QM_DATA_preC1CsCount) ~= Ns_max, temp = temp + 1; end     % 스무딩 카운터 체크
    
    if temp == 0    % 계산에 필요한 데이터가 있는 경우
        % Carrier-Smoothed Code(CSC) Innovation 계산
        QMData(PRN(k1), COL_QM_DATA_CSCI) = QMData(PRN(k1), COL_QM_DATA_C1C) - (QMData(PRN(k1), COL_QM_DATA_preC1Cs) + QMData(PRN(k1), COL_QM_DATA_L1C) - QMData(PRN(k1), COL_QM_DATA_preL1C));
        
        % Threshold 계산
        el = QMData(PRN(k1), COL_QM_DATA_EL)*180/pi;   % unit: degree
        if el < CONST_QM_MaskAngle, el = CONST_QM_MaskAngle; end
        if el > QMThresholds{1,COL_QM_CSCI}(1, COL_QM_Th_MAXEL), el = QMThresholds{1,COL_QM_CSCI}(1, COL_QM_Th_MAXEL); end
        
        threshold_temp1 = QMThresholds{1,COL_QM_CSCI}(1, COL_QM_Th_mean);
        threshold_temp2 = QMThresholds{1,COL_QM_CSCI}(1, COL_QM_Th_coefficient(CONST_QM_PolyOrder+1));
        for k2 = 1:CONST_QM_PolyOrder
            threshold_temp2 = threshold_temp2 + (QMThresholds{1,COL_QM_CSCI}(PRN(k1), COL_QM_Th_coefficient(k2))) * el^(CONST_QM_PolyOrder+1-k2);
        end
        threshold_high = threshold_temp1 + threshold_temp2;
        threshold_low = threshold_temp1 - threshold_temp2;
        
        % 테스트
        if (QMData(PRN(k1), COL_QM_DATA_CSCI) > threshold_high) || (QMData(PRN(k1), COL_QM_DATA_CSCI) < threshold_low)
            Flags(k1, 1) = 1;
        end
    else            % 계산에 필요한 데이터가 없는 경우
        % 테스트: 플래그 1(이상 신호로 결정)
        Flags(k1, 1) = 1;
    end
end

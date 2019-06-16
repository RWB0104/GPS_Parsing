function [Flags, QMData] = MQM_ARST(QMData, QMThresholds, PRN, NoSV, TimeStep)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MQM: Carrier Acceleration-Ramp-Step Test       %
%                                                %
% Version: 1.0_20080707                          %
% Programmed by SJY                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global CONST_Tau_d CONST_QM_MaskAngle CONST_QM_PolyOrder
global COL_QM_Acc COL_QM_Ramp COL_QM_Step
global COL_QM_DATA_L1Ccorr10 COL_QM_DATA_EL 
global COL_QM_DATA_Acc COL_QM_DATA_Ramp COL_QM_DATA_Step
global COL_QM_Th_mean COL_QM_Th_coefficient COL_QM_Th_MAXEL

Flags = zeros(NoSV, 3);

% Carrier Acceleration-Ramp-Step Test
for k = 1:NoSV
    % 계산에 필요한 데이터 유무 체크 결과에 따른 테스트
    temp = sum(isnan(QMData(PRN(k), COL_QM_DATA_L1Ccorr10)));
    
    if temp == 0    % 계산에 필요한 데이터가 있는 경우
        % Carrier Acceleration-Ramp-Step 계산
        
%         QMData(PRN(k), COL_QM_DATA_Acc) = ;
%         QMData(PRN(k), COL_QM_DATA_Ramp) = ;
%         QMData(PRN(k), COL_QM_DATA_Step) = ;
        
        % Threshold 계산 : Acceleration
        el = QMData(PRN(k), COL_QM_DATA_EL)*180/pi;   % unit: degree
        if el < CONST_QM_MaskAngle, el = CONST_QM_MaskAngle; end
        if el > QMThresholds{1,COL_QM_Acc}(1, COL_QM_Th_MAXEL), el = QMThresholds{1,COL_QM_Acc}(1, COL_QM_Th_MAXEL); end
        
        threshold_temp1 = QMThresholds{1,COL_QM_Acc}(1, COL_QM_Th_mean);
        threshold_temp2 = QMThresholds{1,COL_QM_Acc}(1, COL_QM_Th_coefficient(CONST_QM_PolyOrder+1));
        for k1 = 1:CONST_QM_PolyOrder
            threshold_temp2 = threshold_temp2 + (QMThresholds{1,COL_QM_Acc}(PRN(k), COL_QM_Th_coefficient(k1))) * el^(CONST_QM_PolyOrder+1-k1);
        end
        threshold_high = threshold_temp1 + threshold_temp2;
        threshold_low = threshold_temp1 - threshold_temp2;
        
        % 테스트 : Acceleration
        if (QMData(PRN(k), COL_QM_DATA_Acc) > threshold_high) || (QMData(PRN(k), COL_QM_DATA_Acc) < threshold_low)
            Flags(k, 1) = 1;
        end
        
        % Threshold 계산 : Ramp
        el = QMData(PRN(k), COL_QM_DATA_EL)*180/pi;   % unit: degree
        if el < CONST_QM_MaskAngle, el = CONST_QM_MaskAngle; end
        if el > QMThresholds{1,COL_QM_Ramp}(1, COL_QM_Th_MAXEL), el = QMThresholds{1,COL_QM_Ramp}(1, COL_QM_Th_MAXEL); end
        
        threshold_temp1 = QMThresholds{1,COL_QM_Ramp}(1, COL_QM_Th_mean);
        threshold_temp2 = QMThresholds{1,COL_QM_Ramp}(1, COL_QM_Th_coefficient(CONST_QM_PolyOrder+1));
        for k1 = 1:CONST_QM_PolyOrder
            threshold_temp2 = threshold_temp2 + (QMThresholds{1,COL_QM_Ramp}(PRN(k), COL_QM_Th_coefficient(k1))) * el^(CONST_QM_PolyOrder+1-k1);
        end
        threshold_high = threshold_temp1 + threshold_temp2;
        threshold_low = threshold_temp1 - threshold_temp2;
        
        % 테스트 : Ramp
        if (QMData(PRN(k), COL_QM_DATA_Ramp) > threshold_high) || (QMData(PRN(k), COL_QM_DATA_Ramp) < threshold_low)
            Flags(k, 2) = 1;
        end
        
        % Threshold 계산 : Step
        el = QMData(PRN(k), COL_QM_DATA_EL)*180/pi;   % unit: degree
        if el < CONST_QM_MaskAngle, el = CONST_QM_MaskAngle; end
        if el > QMThresholds{1,COL_QM_Step}(1, COL_QM_Th_MAXEL), el = QMThresholds{1,COL_QM_Step}(1, COL_QM_Th_MAXEL); end
        
        threshold_temp1 = QMThresholds{1,COL_QM_Step}(1, COL_QM_Th_mean);
        threshold_temp2 = QMThresholds{1,COL_QM_Step}(1, COL_QM_Th_coefficient(CONST_QM_PolyOrder+1));
        for k1 = 1:CONST_QM_PolyOrder
            threshold_temp2 = threshold_temp2 + (QMThresholds{1,COL_QM_Step}(PRN(k), COL_QM_Th_coefficient(k1))) * el^(CONST_QM_PolyOrder+1-k1);
        end
        threshold_high = threshold_temp1 + threshold_temp2;
        threshold_low = threshold_temp1 - threshold_temp2;
        
        % 테스트 : Step
        if (QMData(PRN(k), COL_QM_DATA_Step) > threshold_high) || (QMData(PRN(k), COL_QM_DATA_Step) < threshold_low)
            Flags(k, 3) = 1;
        end
    else            % 계산에 필요한 데이터가 없는 경우
        % 테스트: 플래그 1(이상 신호로 결정)
        Flags(k, 1:3) = 1;
    end
end

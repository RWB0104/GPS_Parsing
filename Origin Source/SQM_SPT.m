function [Flags, QMData] = SQM_SPT(QMData, QMThresholds, PRN, NoSV)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SQM: Received Signal Power Test                %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by SJY                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global CONST_QM_MaskAngle CONST_QM_PolyOrder
global COL_QM_CN0avg
global COL_QM_DATA_S1C COL_QM_DATA_preS1C COL_QM_DATA_EL
global COL_QM_DATA_CN0avg 
global COL_QM_Th_coefficient COL_QM_Th_MAXEL

Flags = zeros(NoSV, 1);

% Received Signal Power Test
for k1=1:NoSV
    % 계산에 필요한 데이터 유무 체크 결과에 따른 테스트
    temp = isnan(QMData(PRN(k1), COL_QM_DATA_preS1C)) + isnan(QMData(PRN(k1), COL_QM_DATA_S1C));
    
    if temp == 0    % 계산에 필요한 데이터가 있는 경우
        % C/N0 average 계산
        QMData(PRN(k1), COL_QM_DATA_CN0avg) = 0.5 * (QMData(PRN(k1), COL_QM_DATA_preS1C) + QMData(PRN(k1), COL_QM_DATA_S1C));
        
        % Threshold 계산
        el = QMData(PRN(k1), COL_QM_DATA_EL)*180/pi;   % unit: degree
        if el < CONST_QM_MaskAngle, el = CONST_QM_MaskAngle; end
        if el > QMThresholds{1,COL_QM_CN0avg}(1, COL_QM_Th_MAXEL), el = QMThresholds{1,COL_QM_CN0avg}(1, COL_QM_Th_MAXEL); end
        
        threshold = QMThresholds{1,COL_QM_CN0avg}(1, COL_QM_Th_coefficient(CONST_QM_PolyOrder+1));
        for k2 = 1:CONST_QM_PolyOrder
            threshold = threshold + (QMThresholds{1,COL_QM_CN0avg}(PRN(k1), COL_QM_Th_coefficient(k2))) * el^(CONST_QM_PolyOrder+1-k2);
        end
        
        % 테스트
        if QMData(PRN(k1), COL_QM_DATA_CN0avg) < threshold
            Flags(k1, 1) = 1;
        end
    else            % 계산에 필요한 데이터가 없는 경우
        % 테스트: 플래그 1(이상 신호로 결정)
        Flags(k1, 1) = 1;
    end
end
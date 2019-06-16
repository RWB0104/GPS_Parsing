function [Flags, QMData] = MQM_LTC(QMData, QMThresholds, PRN, NoSV)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MQM: Receiver Lock Time Check                  %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by SJY                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global CONST_QM_PolyOrder
global COL_QM_LT
global COL_QM_DATA_L1CLockTime
global COL_QM_Th_coefficient

Flags = zeros(NoSV, 1);

% Receiver Lock Time Check
for k1=1:NoSV
    % Threshold 계산
    threshold = QMThresholds{1,COL_QM_LT}(1, COL_QM_Th_coefficient(CONST_QM_PolyOrder+1));
    
    % 테스트
    if QMData(PRN(k1), COL_QM_DATA_L1CLockTime) < threshold
        Flags(k1, 1) = 1;
    end
end

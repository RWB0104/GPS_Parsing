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
    % ��꿡 �ʿ��� ������ ���� üũ ����� ���� �׽�Ʈ
    temp = isnan(QMData(PRN(k1), COL_QM_DATA_preS1C)) + isnan(QMData(PRN(k1), COL_QM_DATA_S1C));
    
    if temp == 0    % ��꿡 �ʿ��� �����Ͱ� �ִ� ���
        % C/N0 average ���
        QMData(PRN(k1), COL_QM_DATA_CN0avg) = 0.5 * (QMData(PRN(k1), COL_QM_DATA_preS1C) + QMData(PRN(k1), COL_QM_DATA_S1C));
        
        % Threshold ���
        el = QMData(PRN(k1), COL_QM_DATA_EL)*180/pi;   % unit: degree
        if el < CONST_QM_MaskAngle, el = CONST_QM_MaskAngle; end
        if el > QMThresholds{1,COL_QM_CN0avg}(1, COL_QM_Th_MAXEL), el = QMThresholds{1,COL_QM_CN0avg}(1, COL_QM_Th_MAXEL); end
        
        threshold = QMThresholds{1,COL_QM_CN0avg}(1, COL_QM_Th_coefficient(CONST_QM_PolyOrder+1));
        for k2 = 1:CONST_QM_PolyOrder
            threshold = threshold + (QMThresholds{1,COL_QM_CN0avg}(PRN(k1), COL_QM_Th_coefficient(k2))) * el^(CONST_QM_PolyOrder+1-k2);
        end
        
        % �׽�Ʈ
        if QMData(PRN(k1), COL_QM_DATA_CN0avg) < threshold
            Flags(k1, 1) = 1;
        end
    else            % ��꿡 �ʿ��� �����Ͱ� ���� ���
        % �׽�Ʈ: �÷��� 1(�̻� ��ȣ�� ����)
        Flags(k1, 1) = 1;
    end
end
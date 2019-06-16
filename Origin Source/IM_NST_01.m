% QM test
for k=1:NumOfReceiver
    if NPS.ReFLAGS(k) == 0
        % QM ������ ����
        PRN = NST(k).DATA(:, COL_DATA_PRN);
        NoSV = size(PRN, 1);
        NST(k).DATA(:, COL_DATA_QMFlags) = 0;
        
        QMData{k} = array_QMData(NPS.GPSTIME, NPS.TIMESTEP, NST(k).DATA, QMData{k}, preSmoothing{k}, PRN, NoSV);
        
        % SQM
        [NST(k).DATA(:, COL_DATA_CN0avgFlag), QMData{k}] = SQM_SPT(QMData{k}, QMThresholds, PRN, NoSV);
        [NST(k).DATA(:, COL_DATA_CmCDFlag), QMData{k}] = SQM_CmCDT(QMData{k}, QMThresholds, PRN, NoSV, NPS.TIMESTEP);
        
        % DQM
%         DQM_EmAT
%         DQM_EmET
%         DQM_YEmTET
        
        % MQM
        [NST(k).DATA(:, COL_DATA_LTFlag), QMData{k}] = MQM_LTC(QMData{k}, QMThresholds, PRN, NoSV);
%         [NST(k).DATA(:, COL_DATA_ARSFlag), QMData{k}] = MQM_ARST(QMData{k}, QMThresholds, PRN, NoSV, NPS.TIMESTEP);
        [NST(k).DATA(:, COL_DATA_CSCIFlag), QMData{k}] = MQM_CSCIT(QMData{k}, QMThresholds, PRN, NoSV, NPS.TIMESTEP);
    
        % ��� �÷��� ���� <- QM ���� �ٸ� �κ��� �߰��Ǹ�, �� �κ��� ����
        NST(k).DATA(:,COL_DATA_IMFlag) = sum(NST(k).DATA(:, COL_DATA_QMFlags), 2);
        
        for k1=1:NoSV
            zzz0{k}(PRN(k1), NPS.COUNT) = NST(k).DATA(k1, COL_DATA_LTFlag);
        end
    end
end

% % EXM-I
% % MRCC
% % ���-Monitor
% % MFRT
% % EXM-II

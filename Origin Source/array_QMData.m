function QMData = array_QMData(GPSTime, TimeStep, RawData, QMData, preSmoothing, PRN, NoSV)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QM ���� ������ ���� �� ����                     %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by SJY                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global COL_DATA_C1C COL_DATA_L1C COL_DATA_S1C COL_DATA_L1_LockTime COL_DATA_EL
global COL_pSD_GPSTIME COL_pSD_C1Cs COL_pSD_C1Cs_Count
global COL_QM_DATA_GPSTIME COL_QM_DATA_C1C COL_QM_DATA_preC1C ...
       COL_QM_DATA_preC1Cs COL_QM_DATA_preC1CsCount COL_QM_DATA_L1C COL_QM_DATA_preL1C ...
       COL_QM_DATA_L1Ccorr10 COL_QM_DATA_S1C COL_QM_DATA_preS1C COL_QM_DATA_L1CLockTime COL_QM_DATA_EL
global COL_QM_DATA_CmCD COL_QM_DATA_preCmCD

for k1=1:NoSV
    % �� �����Ϳ��� ���� Ȯ��
    temp01 = (GPSTime - QMData(PRN(k1),COL_QM_DATA_GPSTIME)) / TimeStep;
    temp02 = (GPSTime - preSmoothing(PRN(k1),COL_pSD_GPSTIME)) / TimeStep;
    
    % QM ������ ���� �ð��� �°� ����(GPSTime, CA, L1, CN0L1, LockTimeL1, L1corr, EL)
    % �� ������ ����(�� �����Ͱ� ���� ���, NaN (Not a Number)�� ó��)
    QMData(PRN(k1),COL_QM_DATA_GPSTIME) = GPSTime;
    if temp01 == 1
        QMData(PRN(k1), COL_QM_DATA_preC1C) = QMData(PRN(k1), COL_QM_DATA_C1C);
        QMData(PRN(k1), COL_QM_DATA_preL1C) = QMData(PRN(k1), COL_QM_DATA_L1C);
        QMData(PRN(k1), COL_QM_DATA_preS1C) = QMData(PRN(k1), COL_QM_DATA_S1C);
        QMData(PRN(k1), COL_QM_DATA_preCmCD) = QMData(PRN(k1), COL_QM_DATA_CmCD);
    else
        QMData(PRN(k1), COL_QM_DATA_preC1C) = NaN;
        QMData(PRN(k1), COL_QM_DATA_preL1C) = NaN;
        QMData(PRN(k1), COL_QM_DATA_preS1C) = NaN;
        QMData(PRN(k1), COL_QM_DATA_preCmCD) = NaN;
    end
    if temp02 == 1
        QMData(PRN(k1), COL_QM_DATA_preC1Cs) = preSmoothing(PRN(k1), COL_pSD_C1Cs);
        QMData(PRN(k1), COL_QM_DATA_preC1CsCount) = preSmoothing(PRN(k1), COL_pSD_C1Cs_Count);
    else
        QMData(PRN(k1), COL_QM_DATA_preC1Cs) = NaN;
        QMData(PRN(k1), COL_QM_DATA_preC1CsCount) = NaN;
    end
    % ���� ������ ����(���� �����Ͱ� ���� ���(NaN), NaN (Not a Number)���� �״�� ����)
    QMData(PRN(k1), COL_QM_DATA_C1C) = RawData(k1, COL_DATA_C1C);
    QMData(PRN(k1), COL_QM_DATA_L1C) = RawData(k1, COL_DATA_L1C);
    QMData(PRN(k1), COL_QM_DATA_S1C) = RawData(k1, COL_DATA_S1C);
    QMData(PRN(k1), COL_QM_DATA_L1CLockTime) = RawData(k1, COL_DATA_L1_LockTime);
    
    % : �ݼ��� ����ġ�� 10 epochs ������ ���� <- �Ʒ� �κ� ���ۼ� �ʿ�
%     temp03 = NaN(1,9);
%     if temp01 < 10
%         temp03(1,temp01:9) = QMData(PRN(k1),COL_QM_data_L1Epochs10(1):COL_QM_data_L1Epochs10(10-temp01));
%     end
%     % : ���� �����Ͱ� ���� ���(0), NaN (Not a Number)�� ó��
%     if RawData(k1, COL_DATA_L1C) ~= 0, QMData(PRN(k1), COL_QM_data_L1Epochs10) = [NaN temp03];
%     else QMData(PRN(k1), COL_QM_data_L1Epochs10) = [RawData(k1, COL_DATA_L1C) temp03]; end
    
    QMData(PRN(k1), COL_QM_DATA_EL) = RawData(k1, COL_DATA_EL);
end

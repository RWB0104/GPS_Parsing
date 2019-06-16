%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Caculate the QM Thresholds                     %
%                                                %
% Version: 1.0_20080722                          %
% Programmed by SJY                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization %%
% ������ ������ ���� ���� �̿�
% �������� 100��, ������ ���� �����ʹ� �����Ǿ� ����

clear all
close all
clc

% Initialization
CON_Tau_d = 100;        % Time constant of average (smoothing)
CON_T_s = 0.5;          % GPS measurement update rate
CON_PolyOrder = 4;      % Threshold ���� ���׽� ����
CON_GPS_PRNmax = 32;    % 
CON_QM_MaskAngle = 5;   % 
bdwidth = 5;topbdwidth = 70;scnsize = get(0,'ScreenSize');  % �׸� ��ġ�� ũ�Ⱚ
figure_pos = [bdwidth, topbdwidth - bdwidth, scnsize(3) - bdwidth, scnsize(4) - 2*topbdwidth];

% Thresholds : [���, 4�� ���׽� f*ǥ������(a4, a3, a2, a1, a0), �ִ� ����(5�� ���� ������)]
Th_CN0avg       = zeros(32,CON_PolyOrder+3);
Th_CmCD         = zeros(32,CON_PolyOrder+3);
Th_Acc          = zeros(32,CON_PolyOrder+3);
Th_Rap          = zeros(32,CON_PolyOrder+3);
Th_Step         = zeros(32,CON_PolyOrder+3);
Th_CSCI         = zeros(32,CON_PolyOrder+3);

COL_Th_mean         = 1;
COL_Th_coefficient  = 2:(CON_PolyOrder+2);
COL_Th_maxEL        = CON_PolyOrder+3;
COL_Th_max          = CON_PolyOrder+3;

% Columns
COL_GPSTime     = 1;
COL_CA          = 2;
COL_L1          = 3;
COL_CN0L1       = 4;
COL_LockTimeL1  = 5;
COL_L2Codeless  = 6;
COL_L2          = 7;
COL_CN0L2       = 8;
COL_LockTimeL2  = 9;
COL_EL          = 10;
COL_AZ          = 11;
COL_SVx         = 12;
COL_SVy         = 13;
COL_SVz         = 14;
% COL_SVClkCorr   = 15;
% COL_IonoCorr    = 16;
% COL_TropCorr    = 17;
COL_CA100s      = 18;
% COL_CA100sCount = 19;
% COL_USRe        = 20;
% COL_USRn        = 21;
% COL_USRu        = 22;
% COL_ReClk       = 23;
% COL_N           = 24;
% COL_P           = 25;
% COL_ReUSRe      = 26;
% COL_ReUSRn      = 27;
% COL_ReUSRu      = 28;
COL_temp01      = 29;
% COL_temp02      = 30;

COL_CN0avg      = 31;
COL_CN0avg_resi = 32;
COL_CmCD        = 33;
COL_Acc         = 34;
COL_Rap         = 35;
COL_Step        = 36;
COL_CSCI        = 37;
COL_SQM_temp    = 38;

COL_max         = 38;

%% Threshold: Signal Power %%
close all;
CON_ElBinInterval = 10;     % ����: 1~43 (44 ������ ����(PRN 13 ������ ������ ~44.0X���� �̹Ƿ�) ������, �� �ǹ̴� ����)
CON_Histogram_Bins = 50;    % ����ȭ �� 0~1 ������ bin ��
CON_FigureHandle = 100;
% for k=1:32
for k=6:10
    % 
    data_file = ['.\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.mat'];
%     data_file = ['.\DATA_FILES\SV_DATA_2008082731\SV', num2str(k, '%.2i'), '_1.mat'];
    clear data;load(data_file); % ������ ���Ͽ��� �������� data �� �� ����
    
    data2 = data;
    data_file = ['.\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.mat'];
    clear data;load(data_file); % ������ ���Ͽ��� �������� data �� �� ����
    data = [data; data2]; clear data2
    
    data_row_max = size(data, 1);
    if data_row_max < 1,    % �����Ͱ� ���� ��� �ǳʶ�
        disp(['Processing... : PRN ' num2str(k, '%.2i <- No data')]);
        continue;
    else                    % �����Ͱ� ������, ���
        disp(['Processing... : PRN ' num2str(k, '%.2i')]);
    end
    
%     temp = size(data, 1);
%     data(1, COL_temp01) = 1;
%     data(2:temp, COL_temp01) = data(2:temp, COL_EL) - data(1:temp-1, COL_EL);
%     del_data = find(data(:, COL_temp01) < 0);
%     if(~isempty(del_data)), data(del_data, :) = []; end
    
%     del_data = find(90*pi/180 < data(:, COL_AZ) & data(:, COL_AZ) < 180*pi/180);
%     if(~isempty(del_data)), data(del_data, :) = []; end
    
    data_row_max = size(data, 1);
    
    % C/N0 average
    data(1, COL_CN0avg) = data(1, COL_CN0L1);
    for k1 = 2:data_row_max
        % �� ������ ���� üũ �� ���
        if (data(k1, COL_GPSTime) - data(k1-1, COL_GPSTime)) == CON_T_s
            data(k1, COL_CN0avg) = 0.5 * (data(k1, COL_CN0L1) + data(k1-1, COL_CN0L1));
        else
            data(k1, COL_CN0avg) = data(k1, COL_CN0L1);
%             disp(data(k1, COL_GPSTime));
        end
    end
%     figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi,data(:,COL_CN0avg),'b.');grid on;hold on;
    
    % CN0avg Residual ��� : ���׽����� �����Ͽ� ��� 0�� ���¸� �������
    temp_poly_m = polyfit(data(:,COL_EL)*180/pi,data(:,COL_CN0avg),CON_PolyOrder);
    data(:,COL_CN0avg_resi) = data(:,COL_CN0avg) - polyval(temp_poly_m, data(:,COL_EL)*180/pi);
    figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi,data(:,COL_CN0avg),'b.');grid on;hold on;set(k+CON_FigureHandle,'Position',figure_pos);
    title('C/N_0_\__a_v_g','FontSize',16);set(gca,'FontSize',16);axis([0 90 25 55]);
    xlabel('Elevation (degree)','FontSize',16);ylabel('C/N_0_\__a_v_g (dB-Hz)','FontSize',16);
    
    % ������ ���� ǥ������ ���(CON_ElBinInterval ����: (CON_ElBinInterval/2) ���� �����Ͱ� �ִ� �κк���)
    % (temp�� �ش� �׽�Ʈ ������ ��ü)
    temp = [round((data(:,COL_EL)*180/pi - (CON_ElBinInterval/2)) / CON_ElBinInterval) * CON_ElBinInterval + (CON_ElBinInterval/2), data(:,COL_CN0avg_resi)];    % CON_ElBinInterval ���� ����
    temp1 = min(temp(:,1));                 % ���� �ּҰ�(CON_ElBinInterval ����)
    temp2 = max(temp(:,1));                 % ���� �ִ밪(CON_ElBinInterval ����)
    temp1_1 = round((temp1 - (CON_ElBinInterval/2)) / CON_ElBinInterval) + 1;  % CON_ElBinInterval ���� ���� ī��Ʈ �ּҰ�
    temp2_1 = round((temp2 - (CON_ElBinInterval/2)) / CON_ElBinInterval) + 1;  % CON_ElBinInterval ���� ���� ī��Ʈ �ִ밪
    if temp1_1 > 1  % ���� �ּҰ��� �����Ͱ� �ִ� �κк����̹Ƿ� �����Ͱ� ���� ��쿡 ī���͸� 1���� �����ϵ��� ����
        temp2_1 = temp2_1 - (temp1_1 - 1);
        temp1_1 = 1;
    end
    temp3 = temp2_1 - temp1_1 + 1;          % CON_ElBinInterval ���� ���� ī��Ʈ ��
    
%     temp4 = NaN(4, temp3); % CON_ElBinInterval ���� ����, ���, ǥ������, ���+ǥ������
%     for k1=temp1_1:temp2_1 % �� bin���� ����� �ٽ� ���ϴ� ���(MATLAB �Լ� ���)
%         temp4(1,k1) = k1*CON_ElBinInterval-(CON_ElBinInterval/2);
%         temp5 = find(temp(:,1) == temp4(1,k1));
%         temp4(2,k1) = std(temp(temp5,2));
%         temp4(3,k1) = mean(temp(temp5,2));
%         temp4(4,k1) = temp4(3,k1) - temp4(2,k1);
%     end
    
    temp4 = NaN(4, temp3); % CON_ElBinInterval ���� ����, ���, ǥ������, ���+ǥ������
    for k1=temp1_1:temp2_1 % �� bin�� ����� 0���� ����(0 ������� ��������Ƿ�)
        temp4(1,k1) = temp1 + (k1-1)*CON_ElBinInterval; % temp1: ���� �ּҰ�(CON_ElBinInterval ����)
        temp5 = find(temp(:,1) == temp4(1,k1));
        temp6 = size(temp5, 1);
        temp4(2,k1) = sqrt((sum(temp(temp5,2).^2))/temp6);
%         if (k1 > 1 && (temp4(2,k1-1) < temp4(2,k1))), temp4(2,k1-1) = temp4(2,k1); end      % �������� ���� �κ�
    end
%     if temp4(2,1) < temp4(2,2), temp4(2,1) = temp4(2,2) + (temp4(2,2) - temp4(2,3))/2; end    % �������� ���� �κ�
    % �������� ���� �κ��� ���� �������� ǥ�������� ���� ��찡 ù��° ����Ʈ(5��)�� ��Ÿ���Ƿ� ���
    % ���� ������ ���� �ø� �Ŀ��� ���� ������ ���̴��� Ȯ�� �ʿ�
    figure(k+CON_FigureHandle+50);subplot(2,2,1);plot(temp4(1,:), temp4(2,:), 'bo');hold on;grid on;set(k+CON_FigureHandle+50,'Position',figure_pos);
    title('C/N_0_\__a_v_g Residual Standard Deviation','FontSize',16);set(gca,'FontSize',16);axis([0 90 0 2]);
    xlabel('Elevation (degree)','FontSize',16);ylabel('\sigma (m/s)','FontSize',16);
    for k1=temp1_1:temp2_1          % ���׽� �����ϱ� ���� �������� ����
        if (k1 > 1 && (temp4(2,k1-1) < temp4(2,k1))), temp4(2,k1) = temp4(2,k1-1)*0.80; end
    end
    
    % ������ ���� ǥ������ 4�����׽� ����(a4, a3, a2, a1, a0)
    x = temp4(1,:);
    el_std = temp4(2,:);
    if temp2_1 <= CON_PolyOrder     % CON_ElBinInterval ���� �����Ͱ� �������� �۰ų� ���� ��츦 ���(��, PRN 29)
        temp0 = CON_PolyOrder - temp2_1 + 1;
        temp00 = polyfit(x,el_std,CON_PolyOrder-temp0);
        temp_poly = [zeros(1,temp0) temp00];
    else
        temp_poly = polyfit(x,el_std,CON_PolyOrder);
    end
    
    % �׽�Ʈ���� ����ȭ
    temp(:,1) = data(:,COL_EL)*180/pi;
    temp7 = find(data(:,COL_EL)*180/pi > temp2);
    temp(temp7',1) = temp2;  % CON_ElBinInterval ���� ���� �ִ밪���� ũ��, �� ��������(���)���� ����
    temp(:,3) = polyval(temp_poly,temp(:,1));
    temp(:,4) = temp(:,2) ./ temp(:,3);
    figure(k+CON_FigureHandle+50);subplot(2,2,2);plot(data(:,COL_EL)*180/pi, temp(:,4), '.');grid on;
    title('Normalized C/N_0_\__a_v_g Residual','FontSize',16);set(gca,'FontSize',16);axis([0 90 -8 8]);
    xlabel('Elevation (degree)','FontSize',16);ylabel('C/N_0_\__a_v_g Residual / \sigma','FontSize',16);
    
    % ����ȭ ���� ������׷�
    temp7 = 1/CON_Histogram_Bins;
    temp8 = size(data,1);
    temp1_2 = floor(min(temp(:,4)));    % �ּ� ����ȭ ��(����)
    temp2_2 = ceil(max(temp(:,4)));     % �ִ� ����ȭ ��(����)
    k2 = 0;temp10 = NaN(1,3);
    for k1=temp1_2:temp7:temp2_2
        k2 = k2 + 1;
        temp9 = find(k1 < temp(:,4) & temp(:,4) < (k1+temp7));
        temp10(k2,1) = k1+(temp7/2);
        temp10(k2,2) = size(temp9,1) / (temp8 / CON_Histogram_Bins);    % pdf
        if k1 == temp1_2                                                % cdf
            temp10(k2,3) = temp10(k2,2) / CON_Histogram_Bins;
        else
            temp10(k2,3) = temp10(k2-1,3) + temp10(k2,2) / CON_Histogram_Bins;
        end
    end
    figure(k+CON_FigureHandle+50);subplot(2,2,3);plot(temp10(:,1), temp10(:,2),'.');hold on;grid on;
    title('pdf of Normalized C/N_0_\__a_v_g Residual','FontSize',16);set(gca,'FontSize',16);axis([-8 8 0 0.6]);
    xlabel('C/N_0_\__a_v_g Residual / \sigma','FontSize',16);ylabel('pdf','FontSize',16);
    figure(k+CON_FigureHandle+50);subplot(2,2,4);plot(temp10(:,1), log(temp10(:,2)),'.');hold on;grid on;
    title('Overbounding','FontSize',16);set(gca,'FontSize',16);axis([-8 8 -10 0]);
    xlabel('C/N_0_\__a_v_g Residual / \sigma','FontSize',16);ylabel('ln(pdf)','FontSize',16);
    
    % f ����: Overbounding
    [mu,sigma] = normfit(temp(:,4));
    temp11 = find(temp10(:,2) > 0);     % 0�� �ƴ� ��(������ �ִ� ��)�� ���ϴ� �κ��� Ȯ��
    temp12 = normpdf(temp10(temp11,1),mu,sigma);%temp13 = normcdf(temp10(temp11,1),mu,sigma);
    figure(k+CON_FigureHandle+50);subplot(2,2,3);plot(temp10(temp11,1), temp12,'r-');
    figure(k+CON_FigureHandle+50);subplot(2,2,4);plot(temp10(temp11,1), log(temp12),'r:');
    % ����: f < 2.5, ���� �κп� ���� Overbounding
    temp13 = find(abs(temp10(:,1)) > 2.5);
%     temp13 = find(abs(temp10(:,1)) > 2.2);
    f = 2;  % f�� ����(1~2)
    for k1 = 1:4        % ���� �Ҽ��� �ڸ���
        for k2 = 1:9
            f = f - (10^-k1);
            temp10(:,4) = normpdf(temp10(:,1),mu,f*sigma);
            temp14 = find((temp10(temp13,4) - temp10(temp13,2)) < 0);
            if ~isempty(temp14)
                f = f + (10^-k1);
                break;
            end
        end
    end
    
    temp15 = normpdf(temp10(temp11,1),mu,f*sigma);
    figure(k+CON_FigureHandle+50);subplot(2,2,4);plot(temp10(temp11,1), log(temp15),'r-');
    title(['Overbounding ( f = ' num2str(f) ')'],'FontSize',16);
    
    temp16 = temp1:temp2;
    temp16(2,:) = polyval(temp_poly,temp16(1,:));
    figure(k+CON_FigureHandle+50);subplot(2,2,1);plot(temp16(1,:), temp16(2,:), 'b-');
    figure(k+CON_FigureHandle+50);subplot(2,2,1);plot(temp16(1,:), f*temp16(2,:), 'r-');
    
    % Threshold ����(���, ���� ���� f*ǥ������ ���׽� ���)
    
    
    % Threshold plot
    el = data(:,COL_EL)*180/pi;
    temp17 = find(el < CON_QM_MaskAngle);
    if ~isempty(temp17), el(temp17,1) = CON_QM_MaskAngle; end;
    temp17 = find(el > temp2);      % temp2�� �ִ� ����
    if ~isempty(temp17), el(temp17,1) = temp2; end
    
%     threshold_temp1 = 0;            % ����� 0
%     threshold_temp2 = zeros(size(el,1),1) + 6*f*temp_poly(CON_PolyOrder+1) + temp_poly_m(CON_PolyOrder+1);
%     for k1 = 1:CON_PolyOrder
%         threshold_temp2 = threshold_temp2 + 6*f*temp_poly(k1)+temp_poly_m(k1) * el.^(CON_PolyOrder+1-k1);
%     end
%     figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi, (threshold_temp1 - threshold_temp2), 'r.');
    
    threshold_temp1 = 0;            % ����� 0
    threshold_temp2 = zeros(size(el,1),1) + 6*f*temp_poly(CON_PolyOrder+1) - temp_poly_m(CON_PolyOrder+1);
    for k1 = 1:CON_PolyOrder
        threshold_temp2 = threshold_temp2 + (6*f*temp_poly(k1) - temp_poly_m(k1)) * el.^(CON_PolyOrder+1-k1);
    end
    figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi, (threshold_temp1 - threshold_temp2), 'r.');

%     threshold_temp1 = 0;            % ����� 0
%     threshold_temp2 = zeros(size(el,1),1) + temp_poly_m(CON_PolyOrder+1);
%     for k1 = 1:CON_PolyOrder
%         threshold_temp2 = threshold_temp2 + (temp_poly_m(k1)) * el.^(CON_PolyOrder+1-k1);
%     end
%     figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi, (threshold_temp1 + threshold_temp2), 'r.');
end

%% Threshold: Code-Carrier Divergence %%
close all;
CON_ElBinInterval = 10;     % ����: 1~43 (44 ������ ����(PRN 13 ������ ������ ~44.0X���� �̹Ƿ�) ������, �� �ǹ̴� ����)
CON_Histogram_Bins = 50;    % ����ȭ �� 0~1 ������ bin ��
CON_FigureHandle = 200;
% for k=1:32
for k=6:6
    % 
%     data_file = ['.\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.mat'];
    data_file = ['.\DATA_FILES\SV_DATA_2008082731\SV', num2str(k, '%.2i'), '_1.mat'];
    clear data;load(data_file); % ������ ���Ͽ��� �������� data �� �� ����
    
%     data2 = data;
%     data_file = ['.\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.mat'];
%     clear data;load(data_file); % ������ ���Ͽ��� �������� data �� �� ����
%     data = [data; data2]; clear data2
    
    data_row_max = size(data, 1);
    if data_row_max < 1,    % �����Ͱ� ���� ��� �ǳʶ�
        disp(['Processing... : PRN ' num2str(k, '%.2i <- No data')]);
        continue;
    else                    % �����Ͱ� ������, ���
        disp(['Processing... : PRN ' num2str(k, '%.2i')]);
    end
    
%     del_data = find(90*pi/180 < data(:, COL_AZ) & data(:, COL_AZ) < 180*pi/180);
%     if(~isempty(del_data)), data(del_data, :) = []; end
    
    data_row_max = size(data, 1);
    
    % Code-Carrier Divergence
    data(1, COL_CmCD) = 0;
    for k1 = 2:data_row_max
        % �� ������ ���� üũ �� ���
        if (data(k1, COL_GPSTime) - data(k1-1, COL_GPSTime)) == CON_T_s
%             dz = (data(k1, COL_CA100s) - data(k1, COL_L1)) - (data(k1-1, COL_CA100s) - data(k1-1, COL_L1));
            dz = (data(k1, COL_CA) - data(k1, COL_L1)) - (data(k1-1, COL_CA) - data(k1-1, COL_L1));
            data(k1, COL_CmCD) = ((CON_Tau_d - CON_T_s)/CON_Tau_d)*data(k1-1, COL_CmCD) + (1/CON_Tau_d)*dz;
        else
            data(k1, COL_CmCD) = 0;
        end
    end
    figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi,data(:,COL_CmCD),'k.');grid on;hold on;set(k+CON_FigureHandle,'Position',figure_pos);
    title('CmC Divergence','FontSize',16);set(gca,'FontSize',16);axis([0 90 -0.1 0.1]);
    xlabel('Elevation (degree)','FontSize',16);ylabel('CmC Divergence (m/s)','FontSize',16);
%     temp0 = find(abs(data(:,COL_CmCD)) > 0.05);data(temp0,COL_CmCD) = 0;        % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.020);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.990;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.021);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.989;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.022);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.987;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.023);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.984;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.024);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.980;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.025);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.975;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.026);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.969;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.027);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.962;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.028);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.954;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.029);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.945;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.030);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.935;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi,data(:,COL_CmCD),'b.');grid on;hold on;set(k+CON_FigureHandle,'Position',figure_pos);
    title('CmC Divergence','FontSize',16);set(gca,'FontSize',16);axis([0 90 -0.1 0.1]);
    xlabel('Elevation (degree)','FontSize',16);ylabel('CmC Divergence (m/s)','FontSize',16);
    
    % ������ ���� ǥ������ ���(CON_ElBinInterval ����: (CON_ElBinInterval/2) ���� �����Ͱ� �ִ� �κк���)
    temp = [round((data(:,COL_EL)*180/pi - (CON_ElBinInterval/2)) / CON_ElBinInterval) * CON_ElBinInterval + (CON_ElBinInterval/2), data(:,COL_CmCD)];    % CON_ElBinInterval ���� ����
    temp1 = min(temp(:,1));                 % ���� �ּҰ�(CON_ElBinInterval ����)
    temp2 = max(temp(:,1));                 % ���� �ִ밪(CON_ElBinInterval ����)
    temp1_1 = round((temp1 - (CON_ElBinInterval/2)) / CON_ElBinInterval) + 1;  % CON_ElBinInterval ���� ���� ī��Ʈ �ּҰ�
    temp2_1 = round((temp2 - (CON_ElBinInterval/2)) / CON_ElBinInterval) + 1;  % CON_ElBinInterval ���� ���� ī��Ʈ �ִ밪
    if temp1_1 > 1  % ���� �ּҰ��� �����Ͱ� �ִ� �κк����̹Ƿ� �����Ͱ� ���� ��쿡 ī���͸� 1���� �����ϵ��� ����
        temp2_1 = temp2_1 - (temp1_1 - 1);
        temp1_1 = 1;
    end
    temp3 = temp2_1 - temp1_1 + 1;          % CON_ElBinInterval ���� ���� ī��Ʈ ��
    
%     temp4 = NaN(4, temp3); % CON_ElBinInterval ���� ����, ���, ǥ������, ���+ǥ������
%     for k1=temp1_1:temp2_1 % �� bin���� ����� �ٽ� ���ϴ� ���(MATLAB �Լ� ���)
%         temp4(1,k1) = k1*CON_ElBinInterval-(CON_ElBinInterval/2);
%         temp5 = find(temp(:,1) == temp4(1,k1));
%         temp4(2,k1) = std(temp(temp5,2));
%         temp4(3,k1) = mean(temp(temp5,2));
%         temp4(4,k1) = temp4(3,k1) - temp4(2,k1);
%     end
    
    temp4 = NaN(4, temp3); % CON_ElBinInterval ���� ����, ���, ǥ������, ���+ǥ������
    for k1=temp1_1:temp2_1 % �� bin�� ����� 0���� ����(0 ������� ��������Ƿ�)
        temp4(1,k1) = temp1 + (k1-1)*CON_ElBinInterval; % temp1: ���� �ּҰ�(CON_ElBinInterval ����)
        temp5 = find(temp(:,1) == temp4(1,k1));
        temp6 = size(temp5, 1);
        temp4(2,k1) = sqrt((sum(temp(temp5,2).^2))/temp6);
%         if (k1 > 1 && (temp4(2,k1-1) < temp4(2,k1))), temp4(2,k1-1) = temp4(2,k1); end      % �������� ���� �κ�
%         if (k1 > 1 && (temp4(2,k1-1) < temp4(2,k1))), temp4(2,k1) = temp4(2,k1-1)*0.9; end      % �������� ���� �κ�
    end
%     if temp4(2,1) < temp4(2,2), temp4(2,1) = temp4(2,2) + (temp4(2,2) - temp4(2,3))/2; end  % �������� ���� �κ�
%     if temp4(2,1) < temp4(2,2), temp4(2,1) = temp4(2,2) + (temp4(2,2) - temp4(2,3))/3; end  % �������� ���� �κ�
%     if temp4(2,1) < temp4(2,2), temp4(2,1) = temp4(2,2); end                                % �������� ���� �κ�
%     % �������� ���� �κ��� ���� �������� ǥ�������� ���� ��찡 ù��° ����Ʈ(5��)�� ��Ÿ���Ƿ� ���
%     % ���� ������ ���� �ø� �Ŀ��� ���� ������ ���̴��� Ȯ�� �ʿ�
    figure(k+CON_FigureHandle+50);subplot(2,2,1);plot(temp4(1,:), temp4(2,:), 'bo');hold on;grid on;set(k+CON_FigureHandle+50,'Position',figure_pos);
    title('CmC Divergence Standard Deviation','FontSize',16);set(gca,'FontSize',16);axis([0 90 0 0.03]);
    xlabel('Elevation (degree)','FontSize',16);ylabel('\sigma (m/s)','FontSize',16);
    for k1=temp1_1:temp2_1          % ���׽� �����ϱ� ���� �������� ����
        if (k1 > 1 && (temp4(2,k1-1) < temp4(2,k1))), temp4(2,k1) = temp4(2,k1-1)*0.80; end
    end
    
    % ������ ���� ǥ������ 4�����׽� ����(a4, a3, a2, a1, a0)
    x = temp4(1,:);
    el_std = temp4(2,:);
    if temp2_1 <= CON_PolyOrder     % CON_ElBinInterval ���� �����Ͱ� �������� �۰ų� ���� ��츦 ���(��, PRN 29)
        temp0 = CON_PolyOrder - temp2_1 + 1;
        temp00 = polyfit(x,el_std,CON_PolyOrder-temp0);
        temp_poly = [zeros(1,temp0) temp00];
    else
        temp_poly = polyfit(x,el_std,CON_PolyOrder);
    end
    
    % �׽�Ʈ���� ����ȭ
    temp(:,1) = data(:,COL_EL)*180/pi;
    temp7 = find(data(:,COL_EL)*180/pi > temp2);
    temp(temp7',1) = temp2;  % CON_ElBinInterval ���� ���� �ִ밪���� ũ��, �� ��������(���)���� ����
    temp(:,3) = polyval(temp_poly,temp(:,1));
    temp(:,4) = temp(:,2) ./ temp(:,3);
    figure(k+CON_FigureHandle+50);subplot(2,2,2);plot(data(:,COL_EL)*180/pi, temp(:,4), '.');grid on;
    title('Normalized CmC Divergence','FontSize',16);set(gca,'FontSize',16);axis([0 90 -8 8]);
    xlabel('Elevation (degree)','FontSize',16);ylabel('CmC Divergence / \sigma','FontSize',16);
    
    % ����ȭ ���� ������׷�
    temp7 = 1/CON_Histogram_Bins;
    temp8 = size(data,1);
    temp1_2 = floor(min(temp(:,4)));    % �ּ� ����ȭ ��(����)
    temp2_2 = ceil(max(temp(:,4)));     % �ִ� ����ȭ ��(����)
    k2 = 0;temp10 = NaN(1,3);
    for k1=temp1_2:temp7:temp2_2
        k2 = k2 + 1;
        temp9 = find(k1 < temp(:,4) & temp(:,4) < (k1+temp7));
        temp10(k2,1) = k1+(temp7/2);
        temp10(k2,2) = size(temp9,1) / (temp8 / CON_Histogram_Bins);    % pdf
        if k1 == temp1_2                                                % cdf
            temp10(k2,3) = temp10(k2,2) / CON_Histogram_Bins;
        else
            temp10(k2,3) = temp10(k2-1,3) + temp10(k2,2) / CON_Histogram_Bins;
        end
    end
    figure(k+CON_FigureHandle+50);subplot(2,2,3);plot(temp10(:,1), temp10(:,2),'.');hold on;grid on;
    title('pdf of Normalized CmC Divergence','FontSize',16);set(gca,'FontSize',16);axis([-8 8 0 0.6]);
    xlabel('CmC Divergence / \sigma','FontSize',16);ylabel('pdf','FontSize',16);
    figure(k+CON_FigureHandle+50);subplot(2,2,4);plot(temp10(:,1), log(temp10(:,2)),'.');hold on;grid on;
    title('Overbounding','FontSize',16);set(gca,'FontSize',16);axis([-8 8 -10 0]);
    xlabel('CmC Divergence / \sigma','FontSize',16);ylabel('ln(pdf)','FontSize',16);
    
    % f ����: Overbounding
    [mu,sigma] = normfit(temp(:,4));
    temp11 = find(temp10(:,2) > 0);     % 0�� �ƴ� ��(������ �ִ� ��)�� ���ϴ� �κ��� Ȯ��
    temp12 = normpdf(temp10(temp11,1),mu,sigma);%temp13 = normcdf(temp10(temp11,1),mu,sigma);
    figure(k+CON_FigureHandle+50);subplot(2,2,3);plot(temp10(temp11,1), temp12,'r-');
    figure(k+CON_FigureHandle+50);subplot(2,2,4);plot(temp10(temp11,1), log(temp12),'r:');
    % ����: f < 2.5, ���� �κп� ���� Overbounding
    temp13 = find(abs(temp10(:,1)) > 2.5);
    f = 2;  % f�� ����(1~2)
    for k1 = 1:4        % ���� �Ҽ��� �ڸ���
        for k2 = 1:9
            f = f - (10^-k1);
            temp10(:,4) = normpdf(temp10(:,1),mu,f*sigma);
            temp14 = find((temp10(temp13,4) - temp10(temp13,2)) < 0);
            if ~isempty(temp14)
                f = f + (10^-k1);
                break;
            end
        end
    end
    
    temp15 = normpdf(temp10(temp11,1),mu,f*sigma);
    figure(k+CON_FigureHandle+50);subplot(2,2,4);plot(temp10(temp11,1), log(temp15),'r-');
    title(['Overbounding ( f = ' num2str(f) ')'],'FontSize',16);
    
    temp16 = temp1:temp2;
    temp16(2,:) = polyval(temp_poly,temp16(1,:));
    figure(k+CON_FigureHandle+50);subplot(2,2,1);plot(temp16(1,:), temp16(2,:), 'b-');
    figure(k+CON_FigureHandle+50);subplot(2,2,1);plot(temp16(1,:), f*temp16(2,:), 'r-');
    
    % Threshold ����(���, ���� ���� f*ǥ������ ���׽� ���)
    
    
    % Threshold plot
    el = data(:,COL_EL)*180/pi;
    temp17 = find(el < CON_QM_MaskAngle);
    if ~isempty(temp17), el(temp17,1) = CON_QM_MaskAngle; end;
    temp17 = find(el > temp2);      % temp2�� �ִ� ����
    if ~isempty(temp17), el(temp17,1) = temp2; end
    
    threshold_temp1 = 0;            % ����� 0
    threshold_temp2 = zeros(size(el,1),1) + 6*f*temp_poly(CON_PolyOrder+1);
    for k1 = 1:CON_PolyOrder
        threshold_temp2 = threshold_temp2 + 6*f*temp_poly(k1) * el.^(CON_PolyOrder+1-k1);
    end
    figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi, (threshold_temp1 + threshold_temp2), 'r.');
    figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi, (threshold_temp1 - threshold_temp2), 'r.');
    
    % 
%     figure(k+CON_FigureHandle);plot(rem((data(:,COL_GPSTime)/60/60),48), data(:,COL_CmCD), 'b.');grid on;hold on;
%     figure(k+CON_FigureHandle);plot(rem((data(:,COL_GPSTime)/60/60),48), (threshold_temp1 + threshold_temp2), 'r.');
%     figure(k+CON_FigureHandle);plot(rem((data(:,COL_GPSTime)/60/60),48), (threshold_temp1 - threshold_temp2), 'r.');
end

%% Threshold: Carrier Acceleration %%
% close all;
% CON_ElBinInterval = 15;     % ����: 1~43 (44 ������ ����(PRN 13 ������ ������ ~44.0X���� �̹Ƿ�) ������, �� �ǹ̴� ����)
% CON_Histogram_Bins = 50;    % ����ȭ �� 0~1 ������ bin ��
% CON_FigureHandle = 300;
% for k=1:32
% % for k=1:2
%     % 
%     data_file = ['.\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.mat'];
%     clear data;load(data_file); % ������ ���Ͽ��� �������� data �� �� ����
%     data_row_max = size(data, 1);
%     if data_row_max < 1,    % �����Ͱ� ���� ��� �ǳʶ�
%         disp(['Processing... : PRN ' num2str(k, '%.2i <- No data')]);
%         continue;
%     else                    % �����Ͱ� ������, ���
%         disp(['Processing... : PRN ' num2str(k, '%.2i')]);
%     end
%     
%     % 
%     
% end

%% Threshold: Carrier Ramp %%%%%
% close all;
% CON_ElBinInterval = 15;     % ����: 1~43 (44 ������ ����(PRN 13 ������ ������ ~44.0X���� �̹Ƿ�) ������, �� �ǹ̴� ����)
% CON_Histogram_Bins = 50;    % ����ȭ �� 0~1 ������ bin ��
% CON_FigureHandle = 400;
% for k=1:32
% % for k=1:2
%     % 
%     data_file = ['.\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.mat'];
%     clear data;load(data_file); % ������ ���Ͽ��� �������� data �� �� ����
%     data_row_max = size(data, 1);
%     if data_row_max < 1,    % �����Ͱ� ���� ��� �ǳʶ�
%         disp(['Processing... : PRN ' num2str(k, '%.2i <- No data')]);
%         continue;
%     else                    % �����Ͱ� ������, ���
%         disp(['Processing... : PRN ' num2str(k, '%.2i')]);
%     end
%     
%     % 
%     
% end

%% Threshold: Carrier Step %%
% close all;
% CON_ElBinInterval = 15;     % ����: 1~43 (44 ������ ����(PRN 13 ������ ������ ~44.0X���� �̹Ƿ�) ������, �� �ǹ̴� ����)
% CON_Histogram_Bins = 50;    % ����ȭ �� 0~1 ������ bin ��
% CON_FigureHandle = 500;
% for k=1:32
% % for k=1:2
%     % 
%     data_file = ['.\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.mat'];
%     clear data;load(data_file); % ������ ���Ͽ��� �������� data �� �� ����
%     data_row_max = size(data, 1);
%     if data_row_max < 1,    % �����Ͱ� ���� ��� �ǳʶ�
%         disp(['Processing... : PRN ' num2str(k, '%.2i <- No data')]);
%         continue;
%     else                    % �����Ͱ� ������, ���
%         disp(['Processing... : PRN ' num2str(k, '%.2i')]);
%     end
%     
%     % 
%     
% end

%% Threshold: Carrier-Smoothed Code(CSC) Innovation %%
close all;
CON_ElBinInterval = 10;     % ����: 1~43 (44 ������ ����(PRN 13 ������ ������ ~44.0X���� �̹Ƿ�) ������, �� �ǹ̴� ����)
CON_Histogram_Bins = 50;    % ����ȭ �� 0~1 ������ bin ��
CON_FigureHandle = 600;
% for k=1:32
for k=6:6
    % 
%     data_file = ['.\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.mat'];
    data_file = ['.\DATA_FILES\SV_DATA_2008082731\SV', num2str(k, '%.2i'), '_1.mat'];
    clear data;load(data_file); % ������ ���Ͽ��� �������� data �� �� ����
    
%     data2 = data;
%     data_file = ['.\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.mat'];
%     clear data;load(data_file); % ������ ���Ͽ��� �������� data �� �� ����
%     data = [data; data2]; clear data2
    
    data_row_max = size(data, 1);
    if data_row_max < 1,    % �����Ͱ� ���� ��� �ǳʶ�
        disp(['Processing... : PRN ' num2str(k, '%.2i <- No data')]);
        continue;
    else                    % �����Ͱ� ������, ���
        disp(['Processing... : PRN ' num2str(k, '%.2i')]);
    end
    
%     del_data = find(90*pi/180 < data(:, COL_AZ) & data(:, COL_AZ) < 180*pi/180);
%     if(~isempty(del_data)), data(del_data, :) = []; end
    
    data_row_max = size(data, 1);
    
    % Carrier-Smoothed Code(CSC) Innovation
    data(1, COL_CSCI) = 0;
    for k1 = 2:data_row_max
        % �� ������ ���� üũ �� ���
%         temp = isnan(QM_data(COL_QM_data_CA)) + isnan(QM_data(PRN(k), COL_QM_data_preCAs)) + ...
%            isnan(QM_data(COL_QM_data_L1)) + isnan(QM_data(PRN(k), COL_QM_data_preL1));
        if (data(k1, COL_GPSTime) - data(k1-1, COL_GPSTime)) == CON_T_s
            data(k1, COL_CSCI) = data(k1, COL_CA) - (data(k1-1, COL_CA100s) + data(k1, COL_L1) - data(k1-1, COL_L1));
        else
            data(k1, COL_CSCI) = 0;
        end
    end
    figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi,data(:,COL_CSCI),'k.');grid on;hold on;set(k+CON_FigureHandle,'Position',figure_pos);
    title('CSC Innovation','FontSize',16);set(gca,'FontSize',16);axis([0 90 -10 10]);
    xlabel('Elevation (degree)','FontSize',16);ylabel('CSC Innovation (m/s)','FontSize',16);
%     temp0 = find(abs(data(:,COL_CSCI)) > 10);data(temp0,COL_CSCI) = 0;          % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.0);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.990;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.1);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.989;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.2);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.987;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.3);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.984;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.4);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.980;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.5);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.975;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.6);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.969;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.7);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.962;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.8);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.954;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.9);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.945;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 3.0);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.935;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi,data(:,COL_CSCI),'b.');grid on;hold on;set(k+CON_FigureHandle,'Position',figure_pos);
    title('CSC Innovation','FontSize',16);set(gca,'FontSize',16);axis([0 90 -10 10]);
    xlabel('Elevation (degree)','FontSize',16);ylabel('CSC Innovation (m/s)','FontSize',16);
    
    % ������ ���� ǥ������ ���(CON_ElBinInterval ����: (CON_ElBinInterval/2) ���� �����Ͱ� �ִ� �κк���)
    temp = [round((data(:,COL_EL)*180/pi - (CON_ElBinInterval/2)) / CON_ElBinInterval) * CON_ElBinInterval + (CON_ElBinInterval/2), data(:,COL_CSCI)];    % CON_ElBinInterval ���� ����
    temp1 = min(temp(:,1));                 % ���� �ּҰ�(CON_ElBinInterval ����)
    temp2 = max(temp(:,1));                 % ���� �ִ밪(CON_ElBinInterval ����)
    temp1_1 = round((temp1 - (CON_ElBinInterval/2)) / CON_ElBinInterval) + 1;  % CON_ElBinInterval ���� ���� ī��Ʈ �ּҰ�
    temp2_1 = round((temp2 - (CON_ElBinInterval/2)) / CON_ElBinInterval) + 1;  % CON_ElBinInterval ���� ���� ī��Ʈ �ִ밪
    if temp1_1 > 1  % ���� �ּҰ��� �����Ͱ� �ִ� �κк����̹Ƿ� �����Ͱ� ���� ��쿡 ī���͸� 1���� �����ϵ��� ����
        temp2_1 = temp2_1 - (temp1_1 - 1);
        temp1_1 = 1;
    end
    temp3 = temp2_1 - temp1_1 + 1;          % CON_ElBinInterval ���� ���� ī��Ʈ ��
    
%     temp4 = NaN(4, temp3); % CON_ElBinInterval ���� ����, ���, ǥ������, ���+ǥ������
%     for k1=temp1_1:temp2_1 % �� bin���� ����� �ٽ� ���ϴ� ���(MATLAB �Լ� ���)
%         temp4(1,k1) = k1*CON_ElBinInterval-(CON_ElBinInterval/2);
%         temp5 = find(temp(:,1) == temp4(1,k1));
%         temp4(2,k1) = std(temp(temp5,2));
%         temp4(3,k1) = mean(temp(temp5,2));
%         temp4(4,k1) = temp4(3,k1) - temp4(2,k1);
%     end
    
    temp4 = NaN(4, temp3); % CON_ElBinInterval ���� ����, ���, ǥ������, ���+ǥ������
    for k1=temp1_1:temp2_1 % �� bin�� ����� 0���� ����(0 ������� ��������Ƿ�)
        temp4(1,k1) = temp1 + (k1-1)*CON_ElBinInterval; % temp1: ���� �ּҰ�(CON_ElBinInterval ����)
        temp5 = find(temp(:,1) == temp4(1,k1));
        temp6 = size(temp5, 1);
        temp4(2,k1) = sqrt((sum(temp(temp5,2).^2))/temp6);
%         if (k1 > 1 && (temp4(2,k1-1) < temp4(2,k1))), temp4(2,k1-1) = temp4(2,k1); end      % �������� ���� �κ�
%         if (k1 > 1 && (temp4(2,k1-1) < temp4(2,k1))), temp4(2,k1) = temp4(2,k1-1)*0.80; end      % �������� ���� �κ�
    end
%     if temp4(2,1) < temp4(2,2), temp4(2,1) = temp4(2,2) + (temp4(2,2) - temp4(2,3))/2; end    % �������� ���� �κ�
%     % �������� ���� �κ��� ���� �������� ǥ�������� ���� ��찡 ù��° ����Ʈ(5��)�� ��Ÿ���Ƿ� ���
%     % ���� ������ ���� �ø� �Ŀ��� ���� ������ ���̴��� Ȯ�� �ʿ�
    figure(k+CON_FigureHandle+50);subplot(2,2,1);plot(temp4(1,:), temp4(2,:), 'bo');hold on;grid on;set(k+CON_FigureHandle+50,'Position',figure_pos);
    title('CSC Innovation Standard Deviation','FontSize',16);set(gca,'FontSize',16);axis([0 90 0 1.5]);
    xlabel('Elevation (degree)','FontSize',16);ylabel('\sigma (m/s)','FontSize',16);
    for k1=temp1_1:temp2_1          % ���׽� �����ϱ� ���� �������� ����
        if (k1 > 1 && (temp4(2,k1-1) < temp4(2,k1))), temp4(2,k1) = temp4(2,k1-1)*0.80; end
    end
    
    % ������ ���� ǥ������ 4�����׽� ����(a4, a3, a2, a1, a0)
    x = temp4(1,:);
    el_std = temp4(2,:);
    if temp2_1 <= CON_PolyOrder     % CON_ElBinInterval ���� �����Ͱ� �������� �۰ų� ���� ��츦 ���(��, PRN 29)
        temp0 = CON_PolyOrder - temp2_1 + 1;
        temp00 = polyfit(x,el_std,CON_PolyOrder-temp0);
        temp_poly = [zeros(1,temp0) temp00];
    else
        temp_poly = polyfit(x,el_std,CON_PolyOrder);
    end
    
    % �׽�Ʈ���� ����ȭ
    temp(:,1) = data(:,COL_EL)*180/pi;
    temp7 = find(data(:,COL_EL)*180/pi > temp2);
    temp(temp7',1) = temp2;  % CON_ElBinInterval ���� ���� �ִ밪���� ũ��, �� ��������(���)���� ����
    temp(:,3) = polyval(temp_poly,temp(:,1));
    temp(:,4) = temp(:,2) ./ temp(:,3);
    figure(k+CON_FigureHandle+50);subplot(2,2,2);plot(data(:,COL_EL)*180/pi, temp(:,4), '.');grid on;
    title('Normalized CSC Innovation','FontSize',16);set(gca,'FontSize',16);axis([0 90 -8 8]);
    xlabel('Elevation (degree)','FontSize',16);ylabel('CSC Innovation / \sigma','FontSize',16);
    
    % ����ȭ ���� ������׷�
    temp7 = 1/CON_Histogram_Bins;
    temp8 = size(data,1);
    temp1_2 = floor(min(temp(:,4)));    % �ּ� ����ȭ ��(����)
    temp2_2 = ceil(max(temp(:,4)));     % �ִ� ����ȭ ��(����)
    k2 = 0;temp10 = NaN(1,3);
    for k1=temp1_2:temp7:temp2_2
        k2 = k2 + 1;
        temp9 = find(k1 < temp(:,4) & temp(:,4) < (k1+temp7));
        temp10(k2,1) = k1+(temp7/2);
        temp10(k2,2) = size(temp9,1) / (temp8 / CON_Histogram_Bins);    % pdf
        if k1 == temp1_2                                                % cdf
            temp10(k2,3) = temp10(k2,2) / CON_Histogram_Bins;
        else
            temp10(k2,3) = temp10(k2-1,3) + temp10(k2,2) / CON_Histogram_Bins;
        end
    end
    figure(k+CON_FigureHandle+50);subplot(2,2,3);plot(temp10(:,1), temp10(:,2),'.');hold on;grid on;
    title('pdf of Normalized CSC Innovation','FontSize',16);set(gca,'FontSize',16);axis([-8 8 0 0.6]);
    xlabel('CSC Innovation / \sigma','FontSize',16);ylabel('pdf','FontSize',16);
    figure(k+CON_FigureHandle+50);subplot(2,2,4);plot(temp10(:,1), log(temp10(:,2)),'.');hold on;grid on;
    title('Overbounding','FontSize',16);set(gca,'FontSize',16);axis([-8 8 -10 0]);
    xlabel('CSC Innovation / \sigma','FontSize',16);ylabel('ln(pdf)','FontSize',16);
    
    % f ����: Overbounding
    [mu,sigma] = normfit(temp(:,4));
    temp11 = find(temp10(:,2) > 0);     % 0�� �ƴ� ��(������ �ִ� ��)�� ���ϴ� �κ��� Ȯ��
    temp12 = normpdf(temp10(temp11,1),mu,sigma);%temp13 = normcdf(temp10(temp11,1),mu,sigma);
    figure(k+CON_FigureHandle+50);subplot(2,2,3);plot(temp10(temp11,1), temp12,'r-');
    figure(k+CON_FigureHandle+50);subplot(2,2,4);plot(temp10(temp11,1), log(temp12),'r:');
    % ����: f < 2.5, ���� �κп� ���� Overbounding
    temp13 = find(abs(temp10(:,1)) > 2.5);
    f = 2;  % f�� ����(1~2)
    for k1 = 1:4        % ���� �Ҽ��� �ڸ���
        for k2 = 1:9
            f = f - (10^-k1);
            temp10(:,4) = normpdf(temp10(:,1),mu,f*sigma);
            temp14 = find((temp10(temp13,4) - temp10(temp13,2)) < 0);
            if ~isempty(temp14)
                f = f + (10^-k1);
                break;
            end
        end
    end
    
    temp15 = normpdf(temp10(temp11,1),mu,f*sigma);
    figure(k+CON_FigureHandle+50);subplot(2,2,4);plot(temp10(temp11,1), log(temp15),'r-');
    title(['Overbounding ( f = ' num2str(f) ')'],'FontSize',16);
    
    temp16 = temp1:temp2;
    temp16(2,:) = polyval(temp_poly,temp16(1,:));
    figure(k+CON_FigureHandle+50);subplot(2,2,1);plot(temp16(1,:), temp16(2,:), 'b-');
    figure(k+CON_FigureHandle+50);subplot(2,2,1);plot(temp16(1,:), f*temp16(2,:), 'r-');
    
    % Threshold ����(���, ���� ���� f*ǥ������ ���׽� ���)
    
    
    % Threshold plot
    el = data(:,COL_EL)*180/pi;
    temp17 = find(el < CON_QM_MaskAngle);
    if ~isempty(temp17), el(temp17,1) = CON_QM_MaskAngle; end;
    temp17 = find(el > temp2);      % temp2�� �ִ� ����
    if ~isempty(temp17), el(temp17,1) = temp2; end
    
    threshold_temp1 = 0;            % ����� 0
    threshold_temp2 = zeros(size(el,1),1) + 6*f*temp_poly(CON_PolyOrder+1);
    for k1 = 1:CON_PolyOrder
        threshold_temp2 = threshold_temp2 + 6*f*temp_poly(k1) * el.^(CON_PolyOrder+1-k1);
    end
    figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi, (threshold_temp1 + threshold_temp2), 'r.');
    figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi, (threshold_temp1 - threshold_temp2), 'r.');
    
    % 
    temp_t = gps2utc([rem(floor(data(:,COL_GPSTime) ./ (60*60*24*7)), 1024), rem(data(:,COL_GPSTime), 60*60*24*7)], 0);
    temp = rem(temp_t(:, 3),7)*24 + temp_t(:, 4) + temp_t(:, 5)/60 + temp_t(:, 6)/60/60;    % UTC �ú���
    figure(k+CON_FigureHandle+1000);plot(temp, data(:,COL_CSCI), 'b.');grid on;hold on;set(k+CON_FigureHandle+1000,'Position',figure_pos);
    title('CSC Innovation','FontSize',20);set(gca,'FontSize',20);xlabel('GPS time (hour)','FontSize',20);ylabel('CSC Innovation (m/s)','FontSize',20);
    figure(k+CON_FigureHandle+1000);plot(temp, data(:,COL_CSCI), 'b.');grid on;hold on;
    figure(k+CON_FigureHandle+1000);plot(temp, (threshold_temp1 + threshold_temp2), 'r.');
    figure(k+CON_FigureHandle+1000);plot(temp, (threshold_temp1 - threshold_temp2), 'r.');
end
























%% Threshold: Code-Carrier Divergence %%
close all;
CON_ElBinInterval = 10;     % ����: 1~43 (44 ������ ����(PRN 13 ������ ������ ~44.0X���� �̹Ƿ�) ������, �� �ǹ̴� ����)
CON_Histogram_Bins = 50;    % ����ȭ �� 0~1 ������ bin ��
CON_FigureHandle = 200;
% for k=1:32
for k=6:6
    % 
%     data_file = ['.\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.mat'];
    data_file = ['.\DATA_FILES\SV_DATA_2008082731\SV', num2str(k, '%.2i'), '_1.mat'];
    clear data;load(data_file); % ������ ���Ͽ��� �������� data �� �� ����
    
%     data2 = data;
%     data_file = ['.\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.mat'];
%     clear data;load(data_file); % ������ ���Ͽ��� �������� data �� �� ����
%     data = [data; data2]; clear data2
    
    data_row_max = size(data, 1);
    if data_row_max < 1,    % �����Ͱ� ���� ��� �ǳʶ�
        disp(['Processing... : PRN ' num2str(k, '%.2i <- No data')]);
        continue;
    else                    % �����Ͱ� ������, ���
        disp(['Processing... : PRN ' num2str(k, '%.2i')]);
    end
    
%     del_data = find(90*pi/180 < data(:, COL_AZ) & data(:, COL_AZ) < 180*pi/180);
%     if(~isempty(del_data)), data(del_data, :) = []; end
    
    data_row_max = size(data, 1);
    
    % Code-Carrier Divergence
    data(1, COL_CmCD) = 0;
    for k1 = 2:data_row_max
        % �� ������ ���� üũ �� ���
        if (data(k1, COL_GPSTime) - data(k1-1, COL_GPSTime)) == CON_T_s
%             dz = (data(k1, COL_CA100s) - data(k1, COL_L1)) - (data(k1-1, COL_CA100s) - data(k1-1, COL_L1));
            dz = (data(k1, COL_CA) - data(k1, COL_L1)) - (data(k1-1, COL_CA) - data(k1-1, COL_L1));
            data(k1, COL_CmCD) = ((CON_Tau_d - CON_T_s)/CON_Tau_d)*data(k1-1, COL_CmCD) + (1/CON_Tau_d)*dz;
        else
            data(k1, COL_CmCD) = 0;
        end
    end
    figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi,data(:,COL_CmCD),'k.');grid on;hold on;set(k+CON_FigureHandle,'Position',figure_pos);
    title('CmC Divergence','FontSize',20);set(gca,'FontSize',20);axis([0 90 -0.1 0.1]);
    xlabel('Elevation (degree)','FontSize',20);ylabel('CmC Divergence (m/s)','FontSize',20);
%     temp0 = find(abs(data(:,COL_CmCD)) > 0.05);data(temp0,COL_CmCD) = 0;        % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
%     temp0 = find(abs(data(:,COL_CmCD)) > 0.020);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.990;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
%     temp0 = find(abs(data(:,COL_CmCD)) > 0.021);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.989;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
%     temp0 = find(abs(data(:,COL_CmCD)) > 0.022);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.987;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
%     temp0 = find(abs(data(:,COL_CmCD)) > 0.023);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.984;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
%     temp0 = find(abs(data(:,COL_CmCD)) > 0.024);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.980;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
%     temp0 = find(abs(data(:,COL_CmCD)) > 0.025);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.975;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
%     temp0 = find(abs(data(:,COL_CmCD)) > 0.026);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.969;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
%     temp0 = find(abs(data(:,COL_CmCD)) > 0.027);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.962;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
%     temp0 = find(abs(data(:,COL_CmCD)) > 0.028);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.954;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
%     temp0 = find(abs(data(:,COL_CmCD)) > 0.029);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.945;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
%     temp0 = find(abs(data(:,COL_CmCD)) > 0.030);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.935;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi,data(:,COL_CmCD),'b.');grid on;hold on;set(k+CON_FigureHandle,'Position',figure_pos);
    title('CmC Divergence','FontSize',20);set(gca,'FontSize',20);axis([0 90 -0.1 0.1]);
    xlabel('Elevation (degree)','FontSize',20);ylabel('CmC Divergence (m/s)','FontSize',20);
    
    % ������ ���� ǥ������ ���(CON_ElBinInterval ����: (CON_ElBinInterval/2) ���� �����Ͱ� �ִ� �κк���)
    temp = [round((data(:,COL_EL)*180/pi - (CON_ElBinInterval/2)) / CON_ElBinInterval) * CON_ElBinInterval + (CON_ElBinInterval/2), data(:,COL_CmCD)];    % CON_ElBinInterval ���� ����
    temp1 = min(temp(:,1));                 % ���� �ּҰ�(CON_ElBinInterval ����)
    temp2 = max(temp(:,1));                 % ���� �ִ밪(CON_ElBinInterval ����)
    temp1_1 = round((temp1 - (CON_ElBinInterval/2)) / CON_ElBinInterval) + 1;  % CON_ElBinInterval ���� ���� ī��Ʈ �ּҰ�
    temp2_1 = round((temp2 - (CON_ElBinInterval/2)) / CON_ElBinInterval) + 1;  % CON_ElBinInterval ���� ���� ī��Ʈ �ִ밪
    if temp1_1 > 1  % ���� �ּҰ��� �����Ͱ� �ִ� �κк����̹Ƿ� �����Ͱ� ���� ��쿡 ī���͸� 1���� �����ϵ��� ����
        temp2_1 = temp2_1 - (temp1_1 - 1);
        temp1_1 = 1;
    end
    temp3 = temp2_1 - temp1_1 + 1;          % CON_ElBinInterval ���� ���� ī��Ʈ ��
    
%     temp4 = NaN(4, temp3); % CON_ElBinInterval ���� ����, ���, ǥ������, ���+ǥ������
%     for k1=temp1_1:temp2_1 % �� bin���� ����� �ٽ� ���ϴ� ���(MATLAB �Լ� ���)
%         temp4(1,k1) = k1*CON_ElBinInterval-(CON_ElBinInterval/2);
%         temp5 = find(temp(:,1) == temp4(1,k1));
%         temp4(2,k1) = std(temp(temp5,2));
%         temp4(3,k1) = mean(temp(temp5,2));
%         temp4(4,k1) = temp4(3,k1) - temp4(2,k1);
%     end
    
    temp4 = NaN(4, temp3); % CON_ElBinInterval ���� ����, ���, ǥ������, ���+ǥ������
    for k1=temp1_1:temp2_1 % �� bin�� ����� 0���� ����(0 ������� ��������Ƿ�)
        temp4(1,k1) = temp1 + (k1-1)*CON_ElBinInterval; % temp1: ���� �ּҰ�(CON_ElBinInterval ����)
        temp5 = find(temp(:,1) == temp4(1,k1));
        temp6 = size(temp5, 1);
        temp4(2,k1) = sqrt((sum(temp(temp5,2).^2))/temp6);
%         if (k1 > 1 && (temp4(2,k1-1) < temp4(2,k1))), temp4(2,k1-1) = temp4(2,k1); end      % �������� ���� �κ�
%         if (k1 > 1 && (temp4(2,k1-1) < temp4(2,k1))), temp4(2,k1) = temp4(2,k1-1)*0.9; end      % �������� ���� �κ�
    end
%     if temp4(2,1) < temp4(2,2), temp4(2,1) = temp4(2,2) + (temp4(2,2) - temp4(2,3))/2; end  % �������� ���� �κ�
%     if temp4(2,1) < temp4(2,2), temp4(2,1) = temp4(2,2) + (temp4(2,2) - temp4(2,3))/3; end  % �������� ���� �κ�
%     if temp4(2,1) < temp4(2,2), temp4(2,1) = temp4(2,2); end                                % �������� ���� �κ�
%     % �������� ���� �κ��� ���� �������� ǥ�������� ���� ��찡 ù��° ����Ʈ(5��)�� ��Ÿ���Ƿ� ���
%     % ���� ������ ���� �ø� �Ŀ��� ���� ������ ���̴��� Ȯ�� �ʿ�
    figure(k+CON_FigureHandle+50+1);plot(temp4(1,:), temp4(2,:), 'bo');hold on;grid on;set(k+CON_FigureHandle+50+1,'Position',figure_pos);
    title('CmC Divergence Standard Deviation','FontSize',20);set(gca,'FontSize',20);axis([0 90 0 0.02]);
    xlabel('Elevation (degree)','FontSize',20);ylabel('\sigma (m/s)','FontSize',20);
    for k1=temp1_1:temp2_1          % ���׽� �����ϱ� ���� �������� ����
        if (k1 > 1 && (temp4(2,k1-1) < temp4(2,k1))), temp4(2,k1) = temp4(2,k1-1)*0.80; end
    end
    
    % ������ ���� ǥ������ 4�����׽� ����(a4, a3, a2, a1, a0)
    x = temp4(1,:);
    el_std = temp4(2,:);
    if temp2_1 <= CON_PolyOrder     % CON_ElBinInterval ���� �����Ͱ� �������� �۰ų� ���� ��츦 ���(��, PRN 29)
        temp0 = CON_PolyOrder - temp2_1 + 1;
        temp00 = polyfit(x,el_std,CON_PolyOrder-temp0);
        temp_poly = [zeros(1,temp0) temp00];
    else
        temp_poly = polyfit(x,el_std,CON_PolyOrder);
    end
    
    % �׽�Ʈ���� ����ȭ
    temp(:,1) = data(:,COL_EL)*180/pi;
    temp7 = find(data(:,COL_EL)*180/pi > temp2);
    temp(temp7',1) = temp2;  % CON_ElBinInterval ���� ���� �ִ밪���� ũ��, �� ��������(���)���� ����
    temp(:,3) = polyval(temp_poly,temp(:,1));
    temp(:,4) = temp(:,2) ./ temp(:,3);
    figure(k+CON_FigureHandle+50+2);plot(data(:,COL_EL)*180/pi, temp(:,4), '.');grid on;set(k+CON_FigureHandle+50+2,'Position',figure_pos);
    title('Normalized CmC Divergence','FontSize',20);set(gca,'FontSize',20);axis([0 90 -8 8]);
    xlabel('Elevation (degree)','FontSize',20);ylabel('CmC Divergence / \sigma','FontSize',20);
    
    % ����ȭ ���� ������׷�
    temp7 = 1/CON_Histogram_Bins;
    temp8 = size(data,1);
    temp1_2 = floor(min(temp(:,4)));    % �ּ� ����ȭ ��(����)
    temp2_2 = ceil(max(temp(:,4)));     % �ִ� ����ȭ ��(����)
    k2 = 0;temp10 = NaN(1,3);
    for k1=temp1_2:temp7:temp2_2
        k2 = k2 + 1;
        temp9 = find(k1 < temp(:,4) & temp(:,4) < (k1+temp7));
        temp10(k2,1) = k1+(temp7/2);
        temp10(k2,2) = size(temp9,1) / (temp8 / CON_Histogram_Bins);    % pdf
        if k1 == temp1_2                                                % cdf
            temp10(k2,3) = temp10(k2,2) / CON_Histogram_Bins;
        else
            temp10(k2,3) = temp10(k2-1,3) + temp10(k2,2) / CON_Histogram_Bins;
        end
    end
    figure(k+CON_FigureHandle+50+3);plot(temp10(:,1), temp10(:,2),'.');hold on;grid on;set(k+CON_FigureHandle+50+3,'Position',figure_pos);
    title('pdf of Normalized CmC Divergence','FontSize',20);set(gca,'FontSize',20);axis([-8 8 0 0.6]);
    xlabel('CmC Divergence / \sigma','FontSize',20);ylabel('pdf','FontSize',20);
    figure(k+CON_FigureHandle+50+4);plot(temp10(:,1), log(temp10(:,2)),'.');hold on;grid on;set(k+CON_FigureHandle+50+4,'Position',figure_pos);
    title('Overbounding','FontSize',20);set(gca,'FontSize',20);axis([-8 8 -10 0]);
    xlabel('CmC Divergence / \sigma','FontSize',20);ylabel('ln(pdf)','FontSize',20);
    
    % f ����: Overbounding
    [mu,sigma] = normfit(temp(:,4));
    temp11 = find(temp10(:,2) > 0);     % 0�� �ƴ� ��(������ �ִ� ��)�� ���ϴ� �κ��� Ȯ��
    temp12 = normpdf(temp10(temp11,1),mu,sigma);%temp13 = normcdf(temp10(temp11,1),mu,sigma);
    figure(k+CON_FigureHandle+50+3);plot(temp10(temp11,1), temp12,'r-');
    figure(k+CON_FigureHandle+50+4);plot(temp10(temp11,1), log(temp12),'r:');
    % ����: f < 2.5, ���� �κп� ���� Overbounding
    temp13 = find(abs(temp10(:,1)) > 2.5);
    f = 2;  % f�� ����(1~2)
    for k1 = 1:4        % ���� �Ҽ��� �ڸ���
        for k2 = 1:9
            f = f - (10^-k1);
            temp10(:,4) = normpdf(temp10(:,1),mu,f*sigma);
            temp14 = find((temp10(temp13,4) - temp10(temp13,2)) < 0);
            if ~isempty(temp14)
                f = f + (10^-k1);
                break;
            end
        end
    end
    
    temp15 = normpdf(temp10(temp11,1),mu,f*sigma);
    figure(k+CON_FigureHandle+50+4);plot(temp10(temp11,1), log(temp15),'r-');
    title(['Overbounding ( f = ' num2str(f) ')'],'FontSize',20);
    
    temp16 = temp1:temp2;
    temp16(2,:) = polyval(temp_poly,temp16(1,:));
    figure(k+CON_FigureHandle+50+1);plot(temp16(1,:), temp16(2,:), 'b-');
    figure(k+CON_FigureHandle+50+1);plot(temp16(1,:), f*temp16(2,:), 'r-');
    
    % Threshold ����(���, ���� ���� f*ǥ������ ���׽� ���)
    
    
    % Threshold plot
    el = data(:,COL_EL)*180/pi;
    temp17 = find(el < CON_QM_MaskAngle);
    if ~isempty(temp17), el(temp17,1) = CON_QM_MaskAngle; end;
    temp17 = find(el > temp2);      % temp2�� �ִ� ����
    if ~isempty(temp17), el(temp17,1) = temp2; end
    
    threshold_temp1 = 0;            % ����� 0
    threshold_temp2 = zeros(size(el,1),1) + 6*f*temp_poly(CON_PolyOrder+1);
    for k1 = 1:CON_PolyOrder
        threshold_temp2 = threshold_temp2 + 6*f*temp_poly(k1) * el.^(CON_PolyOrder+1-k1);
    end
    figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi, (threshold_temp1 + threshold_temp2), 'r.');
    figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi, (threshold_temp1 - threshold_temp2), 'r.');
    
    % 
    temp_t = gps2utc([rem(floor(data(:,COL_GPSTime) ./ (60*60*24*7)), 1024), rem(data(:,COL_GPSTime), 60*60*24*7)], 0);
    temp = rem(temp_t(:, 3),7)*24 + temp_t(:, 4) + temp_t(:, 5)/60 + temp_t(:, 6)/60/60;    % UTC �ú���
    figure(k+CON_FigureHandle+1000);plot(temp, data(:,COL_CmCD), 'b.');grid on;hold on;set(k+CON_FigureHandle+1000,'Position',figure_pos);
    title('CmC Divergence','FontSize',20);set(gca,'FontSize',20);xlabel('GPS time (hour)','FontSize',20);ylabel('CmC Divergence (m/s)','FontSize',20);
    figure(k+CON_FigureHandle+1000);plot(temp, (threshold_temp1 + threshold_temp2), 'r.');
    figure(k+CON_FigureHandle+1000);plot(temp, (threshold_temp1 - threshold_temp2), 'r.');
end

%% Threshold: Code-Carrier Divergence %%
close all;
CON_ElBinInterval = 10;     % ����: 1~43 (44 ������ ����(PRN 13 ������ ������ ~44.0X���� �̹Ƿ�) ������, �� �ǹ̴� ����)
CON_Histogram_Bins = 50;    % ����ȭ �� 0~1 ������ bin ��
CON_FigureHandle = 200;
for k=1:32
% for k=6:6
    % 
%     data_file = ['.\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.mat'];
    data_file = ['.\DATA_FILES\SV_DATA_2008082731\SV', num2str(k, '%.2i'), '_1.mat'];
    clear data;load(data_file); % ������ ���Ͽ��� �������� data �� �� ����
    
%     data2 = data;
%     data_file = ['.\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.mat'];
%     clear data;load(data_file); % ������ ���Ͽ��� �������� data �� �� ����
%     data = [data; data2]; clear data2
    
    data_row_max = size(data, 1);
    if data_row_max < 1,    % �����Ͱ� ���� ��� �ǳʶ�
        disp(['Processing... : PRN ' num2str(k, '%.2i <- No data')]);
        continue;
    else                    % �����Ͱ� ������, ���
        disp(['Processing... : PRN ' num2str(k, '%.2i')]);
    end
    
%     del_data = find(90*pi/180 < data(:, COL_AZ) & data(:, COL_AZ) < 180*pi/180);
%     if(~isempty(del_data)), data(del_data, :) = []; end
    
    data_row_max = size(data, 1);
    
    % Code-Carrier Divergence
    data(1, COL_CmCD) = 0;
    for k1 = 2:data_row_max
        % �� ������ ���� üũ �� ���
        if (data(k1, COL_GPSTime) - data(k1-1, COL_GPSTime)) == CON_T_s
%             dz = (data(k1, COL_CA100s) - data(k1, COL_L1)) - (data(k1-1, COL_CA100s) - data(k1-1, COL_L1));
            dz = (data(k1, COL_CA) - data(k1, COL_L1)) - (data(k1-1, COL_CA) - data(k1-1, COL_L1));
            data(k1, COL_CmCD) = ((CON_Tau_d - CON_T_s)/CON_Tau_d)*data(k1-1, COL_CmCD) + (1/CON_Tau_d)*dz;
        else
            data(k1, COL_CmCD) = 0;
        end
    end
    if k==2
        figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi,data(:,COL_CmCD),'b.');grid on;hold on;set(k+CON_FigureHandle,'Position',figure_pos);
        title('CmC Divergence','FontSize',20);set(gca,'FontSize',20);axis([0 90 -0.1 0.1]);
        xlabel('Elevation (degree)','FontSize',20);ylabel('CmC Divergence (m/s)','FontSize',20);
    end
    temp0 = find(abs(data(:,COL_CmCD)) > 0.05);data(temp0,COL_CmCD) = 0;        % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.020);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.990;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.021);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.989;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.022);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.987;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.023);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.984;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.024);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.980;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.025);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.975;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.026);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.969;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.027);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.962;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.028);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.954;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.029);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.945;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CmCD)) > 0.030);data(temp0,COL_CmCD) = data(temp0,COL_CmCD) * 0.935;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    
    % ������ ���� ǥ������ ���(CON_ElBinInterval ����: (CON_ElBinInterval/2) ���� �����Ͱ� �ִ� �κк���)
    temp = [round((data(:,COL_EL)*180/pi - (CON_ElBinInterval/2)) / CON_ElBinInterval) * CON_ElBinInterval + (CON_ElBinInterval/2), data(:,COL_CmCD)];    % CON_ElBinInterval ���� ����
    temp1 = min(temp(:,1));                 % ���� �ּҰ�(CON_ElBinInterval ����)
    temp2 = max(temp(:,1));                 % ���� �ִ밪(CON_ElBinInterval ����)
    temp1_1 = round((temp1 - (CON_ElBinInterval/2)) / CON_ElBinInterval) + 1;  % CON_ElBinInterval ���� ���� ī��Ʈ �ּҰ�
    temp2_1 = round((temp2 - (CON_ElBinInterval/2)) / CON_ElBinInterval) + 1;  % CON_ElBinInterval ���� ���� ī��Ʈ �ִ밪
    if temp1_1 > 1  % ���� �ּҰ��� �����Ͱ� �ִ� �κк����̹Ƿ� �����Ͱ� ���� ��쿡 ī���͸� 1���� �����ϵ��� ����
        temp2_1 = temp2_1 - (temp1_1 - 1);
        temp1_1 = 1;
    end
    temp3 = temp2_1 - temp1_1 + 1;          % CON_ElBinInterval ���� ���� ī��Ʈ ��
    
%     temp4 = NaN(4, temp3); % CON_ElBinInterval ���� ����, ���, ǥ������, ���+ǥ������
%     for k1=temp1_1:temp2_1 % �� bin���� ����� �ٽ� ���ϴ� ���(MATLAB �Լ� ���)
%         temp4(1,k1) = k1*CON_ElBinInterval-(CON_ElBinInterval/2);
%         temp5 = find(temp(:,1) == temp4(1,k1));
%         temp4(2,k1) = std(temp(temp5,2));
%         temp4(3,k1) = mean(temp(temp5,2));
%         temp4(4,k1) = temp4(3,k1) - temp4(2,k1);
%     end
    
    temp4 = NaN(4, temp3); % CON_ElBinInterval ���� ����, ���, ǥ������, ���+ǥ������
    for k1=temp1_1:temp2_1 % �� bin�� ����� 0���� ����(0 ������� ��������Ƿ�)
        temp4(1,k1) = temp1 + (k1-1)*CON_ElBinInterval; % temp1: ���� �ּҰ�(CON_ElBinInterval ����)
        temp5 = find(temp(:,1) == temp4(1,k1));
        temp6 = size(temp5, 1);
        temp4(2,k1) = sqrt((sum(temp(temp5,2).^2))/temp6);
%         if (k1 > 1 && (temp4(2,k1-1) < temp4(2,k1))), temp4(2,k1-1) = temp4(2,k1); end      % �������� ���� �κ�
%         if (k1 > 1 && (temp4(2,k1-1) < temp4(2,k1))), temp4(2,k1) = temp4(2,k1-1)*0.9; end      % �������� ���� �κ�
    end
%     if temp4(2,1) < temp4(2,2), temp4(2,1) = temp4(2,2) + (temp4(2,2) - temp4(2,3))/2; end  % �������� ���� �κ�
%     if temp4(2,1) < temp4(2,2), temp4(2,1) = temp4(2,2) + (temp4(2,2) - temp4(2,3))/3; end  % �������� ���� �κ�
%     if temp4(2,1) < temp4(2,2), temp4(2,1) = temp4(2,2); end                                % �������� ���� �κ�
%     % �������� ���� �κ��� ���� �������� ǥ�������� ���� ��찡 ù��° ����Ʈ(5��)�� ��Ÿ���Ƿ� ���
%     % ���� ������ ���� �ø� �Ŀ��� ���� ������ ���̴��� Ȯ�� �ʿ�
    for k1=temp1_1:temp2_1          % ���׽� �����ϱ� ���� �������� ����
        if (k1 > 1 && (temp4(2,k1-1) < temp4(2,k1))), temp4(2,k1) = temp4(2,k1-1)*0.80; end
    end
    
    % ������ ���� ǥ������ 4�����׽� ����(a4, a3, a2, a1, a0)
    x = temp4(1,:);
    el_std = temp4(2,:);
    if temp2_1 <= CON_PolyOrder     % CON_ElBinInterval ���� �����Ͱ� �������� �۰ų� ���� ��츦 ���(��, PRN 29)
        temp0 = CON_PolyOrder - temp2_1 + 1;
        temp00 = polyfit(x,el_std,CON_PolyOrder-temp0);
        temp_poly = [zeros(1,temp0) temp00];
    else
        temp_poly = polyfit(x,el_std,CON_PolyOrder);
    end
    
    % �׽�Ʈ���� ����ȭ
    temp(:,1) = data(:,COL_EL)*180/pi;
    temp7 = find(data(:,COL_EL)*180/pi > temp2);
    temp(temp7',1) = temp2;  % CON_ElBinInterval ���� ���� �ִ밪���� ũ��, �� ��������(���)���� ����
    temp(:,3) = polyval(temp_poly,temp(:,1));
    temp(:,4) = temp(:,2) ./ temp(:,3);
    
    % ����ȭ ���� ������׷�
    temp7 = 1/CON_Histogram_Bins;
    temp8 = size(data,1);
    temp1_2 = floor(min(temp(:,4)));    % �ּ� ����ȭ ��(����)
    temp2_2 = ceil(max(temp(:,4)));     % �ִ� ����ȭ ��(����)
    k2 = 0;temp10 = NaN(1,3);
    for k1=temp1_2:temp7:temp2_2
        k2 = k2 + 1;
        temp9 = find(k1 < temp(:,4) & temp(:,4) < (k1+temp7));
        temp10(k2,1) = k1+(temp7/2);
        temp10(k2,2) = size(temp9,1) / (temp8 / CON_Histogram_Bins);    % pdf
        if k1 == temp1_2                                                % cdf
            temp10(k2,3) = temp10(k2,2) / CON_Histogram_Bins;
        else
            temp10(k2,3) = temp10(k2-1,3) + temp10(k2,2) / CON_Histogram_Bins;
        end
    end
    
    % f ����: Overbounding
    [mu,sigma] = normfit(temp(:,4));
    temp11 = find(temp10(:,2) > 0);     % 0�� �ƴ� ��(������ �ִ� ��)�� ���ϴ� �κ��� Ȯ��
    temp12 = normpdf(temp10(temp11,1),mu,sigma);%temp13 = normcdf(temp10(temp11,1),mu,sigma);
    % ����: f < 2.5, ���� �κп� ���� Overbounding
    temp13 = find(abs(temp10(:,1)) > 2.5);
    f = 2;  % f�� ����(1~2)
    for k1 = 1:4        % ���� �Ҽ��� �ڸ���
        for k2 = 1:9
            f = f - (10^-k1);
            temp10(:,4) = normpdf(temp10(:,1),mu,f*sigma);
            temp14 = find((temp10(temp13,4) - temp10(temp13,2)) < 0);
            if ~isempty(temp14)
                f = f + (10^-k1);
                break;
            end
        end
    end
    
    temp15 = normpdf(temp10(temp11,1),mu,f*sigma);
    
    temp16 = temp1:temp2;
    temp16(2,:) = polyval(temp_poly,temp16(1,:));
    
    % Threshold ����(���, ���� ���� f*ǥ������ ���׽� ���)
    
    
    % Threshold plot
    el = data(:,COL_EL)*180/pi;
    temp17 = find(el < CON_QM_MaskAngle);
    if ~isempty(temp17), el(temp17,1) = CON_QM_MaskAngle; end;
    temp17 = find(el > temp2);      % temp2�� �ִ� ����
    if ~isempty(temp17), el(temp17,1) = temp2; end
    
    threshold_temp1 = 0;            % ����� 0
    threshold_temp2 = zeros(size(el,1),1) + 6*f*temp_poly(CON_PolyOrder+1);
    for k1 = 1:CON_PolyOrder
        threshold_temp2 = threshold_temp2 + 6*f*temp_poly(k1) * el.^(CON_PolyOrder+1-k1);
    end
    % 
    if k==2
        figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi, (threshold_temp1 + threshold_temp2), 'm.');
        figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi, (threshold_temp1 - threshold_temp2), 'm.');
    else
        figure(2+CON_FigureHandle);plot(data(:,COL_EL)*180/pi, (threshold_temp1 + threshold_temp2), 'r.', 'MarkerSize', 1);
        figure(2+CON_FigureHandle);plot(data(:,COL_EL)*180/pi, (threshold_temp1 - threshold_temp2), 'r.', 'MarkerSize', 1);
    end
end

%% Threshold: Carrier-Smoothed Code(CSC) Innovation %%
close all;
CON_ElBinInterval = 10;     % ����: 1~43 (44 ������ ����(PRN 13 ������ ������ ~44.0X���� �̹Ƿ�) ������, �� �ǹ̴� ����)
CON_Histogram_Bins = 50;    % ����ȭ �� 0~1 ������ bin ��
CON_FigureHandle = 600;
for k=1:32
% for k=6:6
    % 
%     data_file = ['.\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.mat'];
    data_file = ['.\DATA_FILES\SV_DATA_2008082731\SV', num2str(k, '%.2i'), '_1.mat'];
    clear data;load(data_file); % ������ ���Ͽ��� �������� data �� �� ����
    
%     data2 = data;
%     data_file = ['.\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.mat'];
%     clear data;load(data_file); % ������ ���Ͽ��� �������� data �� �� ����
%     data = [data; data2]; clear data2
    
    data_row_max = size(data, 1);
    if data_row_max < 1,    % �����Ͱ� ���� ��� �ǳʶ�
        disp(['Processing... : PRN ' num2str(k, '%.2i <- No data')]);
        continue;
    else                    % �����Ͱ� ������, ���
        disp(['Processing... : PRN ' num2str(k, '%.2i')]);
    end
    
%     del_data = find(90*pi/180 < data(:, COL_AZ) & data(:, COL_AZ) < 180*pi/180);
%     if(~isempty(del_data)), data(del_data, :) = []; end
    
    data_row_max = size(data, 1);
    
    % Carrier-Smoothed Code(CSC) Innovation
    data(1, COL_CSCI) = 0;
    for k1 = 2:data_row_max
        % �� ������ ���� üũ �� ���
%         temp = isnan(QM_data(COL_QM_data_CA)) + isnan(QM_data(PRN(k), COL_QM_data_preCAs)) + ...
%            isnan(QM_data(COL_QM_data_L1)) + isnan(QM_data(PRN(k), COL_QM_data_preL1));
        if (data(k1, COL_GPSTime) - data(k1-1, COL_GPSTime)) == CON_T_s
            data(k1, COL_CSCI) = data(k1, COL_CA) - (data(k1-1, COL_CA100s) + data(k1, COL_L1) - data(k1-1, COL_L1));
        else
            data(k1, COL_CSCI) = 0;
        end
    end
    if k==2
        figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi,data(:,COL_CSCI),'b.');grid on;hold on;set(k+CON_FigureHandle,'Position',figure_pos);
        title('CSC Innovation','FontSize',16);set(gca,'FontSize',16);axis([0 90 -10 10]);
        xlabel('Elevation (degree)','FontSize',16);ylabel('CSC Innovation (m/s)','FontSize',16);
    end
%     temp0 = find(abs(data(:,COL_CSCI)) > 10);data(temp0,COL_CSCI) = 0;          % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.0);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.990;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.1);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.989;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.2);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.987;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.3);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.984;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.4);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.980;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.5);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.975;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.6);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.969;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.7);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.962;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.8);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.954;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 2.9);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.945;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    temp0 = find(abs(data(:,COL_CSCI)) > 3.0);data(temp0,COL_CSCI) = data(temp0,COL_CSCI) * 0.935;    % ��갪�� �Ѱ�ġ(�̻� ���) Ȯ��
    
    % ������ ���� ǥ������ ���(CON_ElBinInterval ����: (CON_ElBinInterval/2) ���� �����Ͱ� �ִ� �κк���)
    temp = [round((data(:,COL_EL)*180/pi - (CON_ElBinInterval/2)) / CON_ElBinInterval) * CON_ElBinInterval + (CON_ElBinInterval/2), data(:,COL_CSCI)];    % CON_ElBinInterval ���� ����
    temp1 = min(temp(:,1));                 % ���� �ּҰ�(CON_ElBinInterval ����)
    temp2 = max(temp(:,1));                 % ���� �ִ밪(CON_ElBinInterval ����)
    temp1_1 = round((temp1 - (CON_ElBinInterval/2)) / CON_ElBinInterval) + 1;  % CON_ElBinInterval ���� ���� ī��Ʈ �ּҰ�
    temp2_1 = round((temp2 - (CON_ElBinInterval/2)) / CON_ElBinInterval) + 1;  % CON_ElBinInterval ���� ���� ī��Ʈ �ִ밪
    if temp1_1 > 1  % ���� �ּҰ��� �����Ͱ� �ִ� �κк����̹Ƿ� �����Ͱ� ���� ��쿡 ī���͸� 1���� �����ϵ��� ����
        temp2_1 = temp2_1 - (temp1_1 - 1);
        temp1_1 = 1;
    end
    temp3 = temp2_1 - temp1_1 + 1;          % CON_ElBinInterval ���� ���� ī��Ʈ ��
    
%     temp4 = NaN(4, temp3); % CON_ElBinInterval ���� ����, ���, ǥ������, ���+ǥ������
%     for k1=temp1_1:temp2_1 % �� bin���� ����� �ٽ� ���ϴ� ���(MATLAB �Լ� ���)
%         temp4(1,k1) = k1*CON_ElBinInterval-(CON_ElBinInterval/2);
%         temp5 = find(temp(:,1) == temp4(1,k1));
%         temp4(2,k1) = std(temp(temp5,2));
%         temp4(3,k1) = mean(temp(temp5,2));
%         temp4(4,k1) = temp4(3,k1) - temp4(2,k1);
%     end
    
    temp4 = NaN(4, temp3); % CON_ElBinInterval ���� ����, ���, ǥ������, ���+ǥ������
    for k1=temp1_1:temp2_1 % �� bin�� ����� 0���� ����(0 ������� ��������Ƿ�)
        temp4(1,k1) = temp1 + (k1-1)*CON_ElBinInterval; % temp1: ���� �ּҰ�(CON_ElBinInterval ����)
        temp5 = find(temp(:,1) == temp4(1,k1));
        temp6 = size(temp5, 1);
        temp4(2,k1) = sqrt((sum(temp(temp5,2).^2))/temp6);
%         if (k1 > 1 && (temp4(2,k1-1) < temp4(2,k1))), temp4(2,k1-1) = temp4(2,k1); end      % �������� ���� �κ�
%         if (k1 > 1 && (temp4(2,k1-1) < temp4(2,k1))), temp4(2,k1) = temp4(2,k1-1)*0.80; end      % �������� ���� �κ�
    end
%     if temp4(2,1) < temp4(2,2), temp4(2,1) = temp4(2,2) + (temp4(2,2) - temp4(2,3))/2; end    % �������� ���� �κ�
%     % �������� ���� �κ��� ���� �������� ǥ�������� ���� ��찡 ù��° ����Ʈ(5��)�� ��Ÿ���Ƿ� ���
%     % ���� ������ ���� �ø� �Ŀ��� ���� ������ ���̴��� Ȯ�� �ʿ�
    for k1=temp1_1:temp2_1          % ���׽� �����ϱ� ���� �������� ����
        if (k1 > 1 && (temp4(2,k1-1) < temp4(2,k1))), temp4(2,k1) = temp4(2,k1-1)*0.80; end
    end
    
    % ������ ���� ǥ������ 4�����׽� ����(a4, a3, a2, a1, a0)
    x = temp4(1,:);
    el_std = temp4(2,:);
    if temp2_1 <= CON_PolyOrder     % CON_ElBinInterval ���� �����Ͱ� �������� �۰ų� ���� ��츦 ���(��, PRN 29)
        temp0 = CON_PolyOrder - temp2_1 + 1;
        temp00 = polyfit(x,el_std,CON_PolyOrder-temp0);
        temp_poly = [zeros(1,temp0) temp00];
    else
        temp_poly = polyfit(x,el_std,CON_PolyOrder);
    end
    
    % �׽�Ʈ���� ����ȭ
    temp(:,1) = data(:,COL_EL)*180/pi;
    temp7 = find(data(:,COL_EL)*180/pi > temp2);
    temp(temp7',1) = temp2;  % CON_ElBinInterval ���� ���� �ִ밪���� ũ��, �� ��������(���)���� ����
    temp(:,3) = polyval(temp_poly,temp(:,1));
    temp(:,4) = temp(:,2) ./ temp(:,3);
    
    % ����ȭ ���� ������׷�
    temp7 = 1/CON_Histogram_Bins;
    temp8 = size(data,1);
    temp1_2 = floor(min(temp(:,4)));    % �ּ� ����ȭ ��(����)
    temp2_2 = ceil(max(temp(:,4)));     % �ִ� ����ȭ ��(����)
    k2 = 0;temp10 = NaN(1,3);
    for k1=temp1_2:temp7:temp2_2
        k2 = k2 + 1;
        temp9 = find(k1 < temp(:,4) & temp(:,4) < (k1+temp7));
        temp10(k2,1) = k1+(temp7/2);
        temp10(k2,2) = size(temp9,1) / (temp8 / CON_Histogram_Bins);    % pdf
        if k1 == temp1_2                                                % cdf
            temp10(k2,3) = temp10(k2,2) / CON_Histogram_Bins;
        else
            temp10(k2,3) = temp10(k2-1,3) + temp10(k2,2) / CON_Histogram_Bins;
        end
    end
    
    % f ����: Overbounding
    [mu,sigma] = normfit(temp(:,4));
    temp11 = find(temp10(:,2) > 0);     % 0�� �ƴ� ��(������ �ִ� ��)�� ���ϴ� �κ��� Ȯ��
    temp12 = normpdf(temp10(temp11,1),mu,sigma);%temp13 = normcdf(temp10(temp11,1),mu,sigma);
    % ����: f < 2.5, ���� �κп� ���� Overbounding
    temp13 = find(abs(temp10(:,1)) > 2.5);
    f = 2;  % f�� ����(1~2)
    for k1 = 1:4        % ���� �Ҽ��� �ڸ���
        for k2 = 1:9
            f = f - (10^-k1);
            temp10(:,4) = normpdf(temp10(:,1),mu,f*sigma);
            temp14 = find((temp10(temp13,4) - temp10(temp13,2)) < 0);
            if ~isempty(temp14)
                f = f + (10^-k1);
                break;
            end
        end
    end
    
    temp15 = normpdf(temp10(temp11,1),mu,f*sigma);
    
    temp16 = temp1:temp2;
    temp16(2,:) = polyval(temp_poly,temp16(1,:));
    
    % Threshold ����(���, ���� ���� f*ǥ������ ���׽� ���)
    
    
    % Threshold plot
    el = data(:,COL_EL)*180/pi;
    temp17 = find(el < CON_QM_MaskAngle);
    if ~isempty(temp17), el(temp17,1) = CON_QM_MaskAngle; end;
    temp17 = find(el > temp2);      % temp2�� �ִ� ����
    if ~isempty(temp17), el(temp17,1) = temp2; end
    
    threshold_temp1 = 0;            % ����� 0
    threshold_temp2 = zeros(size(el,1),1) + 6*f*temp_poly(CON_PolyOrder+1);
    for k1 = 1:CON_PolyOrder
        threshold_temp2 = threshold_temp2 + 6*f*temp_poly(k1) * el.^(CON_PolyOrder+1-k1);
    end
    if k==2
        figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi, (threshold_temp1 + threshold_temp2), 'm.');
        figure(k+CON_FigureHandle);plot(data(:,COL_EL)*180/pi, (threshold_temp1 - threshold_temp2), 'm.');
    else
        figure(2+CON_FigureHandle);plot(data(:,COL_EL)*180/pi, (threshold_temp1 + threshold_temp2), 'r.', 'MarkerSize', 1);
        figure(2+CON_FigureHandle);plot(data(:,COL_EL)*180/pi, (threshold_temp1 - threshold_temp2), 'r.', 'MarkerSize', 1);
    end
end
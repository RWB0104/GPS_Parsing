%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read raw data                                  %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch NST(k).CONF.MODEL
    case MODEL_DLV3_PP
        [NST(k).EPOCH, NST(k).DATA, NST(k).BufferEPH, FileEnd(k)] = read_NovAtel(NST(k).FID, NST(k).EPOCH, NST(k).BufferEPH);
        % ����: ���� �������� ���� Raw DATA�� �����ϴ� ���(��, ����ġ ����), �ٷ� ���� �Լ����� ����Ǵ� mat �����ϴ� �κп� ������ ����
        
        % �Ʒ� ����ġ�� calSVsPos���� ��갪���� �����
%         % SV clock correction <- ���� Ephemeris �����Ϳ����� ����ġ�� �� �� ��ü
%         % OEMV Family Firmware Reference Manual�� SVXYZ ���� �� ����ġ ���� ����(512��, revision 5)
%         NST(k).DATA(:, COL_DATA_C1C) = NST(k).DATA(:, COL_DATA_C1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
%         NST(k).DATA(:, COL_DATA_L1C) = NST(k).DATA(:, COL_DATA_L1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
        
    case MODEL_DLV3_PP_mat01
        if (mat_count(k) == 0) || (mat_count(k) == mat_count_max)       % ó�� ���۰� ���� epoch ������ ���� ����
            mat_file_count(k) = mat_file_count(k) + 1;
            mat_file_name = ['.\DATA_FILES\RAW_2008070910\test_2008070910_', num2str(k, '%.2i'), '_', num2str(mat_file_count(k), '%.3i'), '.mat'];
            load(mat_file_name);
            
            mat_count(k) = 0;
            mat_row = size(mat_data_1, 1);          % ������ ������ ���� ��� ũ�Ⱑ �ٸ� �� �����Ƿ� üũ
            mat_data(1:mat_row, k) = mat_data_1;
        end
        
        mat_count(k) = mat_count(k) + 1;            % ������ ����
        NST(k).EPOCH = mat_data(mat_count(k), k).EPOCH;
        NST(k).DATA = mat_data(mat_count(k), k).DATA;
        if isempty(NST(k).BufferEPH)
            NST(k).BufferEPH = mat_data(mat_count(k), k).BufferEPH;                     % �˵��� ������ ��ġ �κ��� ����Ǵ� ���, ������ �� ����
        else
            NST(k).BufferEPH = [NST(k).BufferEPH; mat_data(mat_count(k), k).BufferEPH]; % �˵��� ������ ��ġ �κ��� ����Ǵ� ���, ������ �� ����
        end
        
        if mat_data(mat_count(k), k).FileEnd == 1   % ���� üũ
            FileEnd(k) = 1;
        end
        
        % �Ʒ� ����ġ�� calSVsPos���� ��갪���� �����
%         % SV clock correction <- ���� Ephemeris �����Ϳ����� ����ġ�� �� �� ��ü
%         % OEMV Family Firmware Reference Manual�� SVXYZ ���� �� ����ġ ���� ����(512��, revision 5)
%         NST(k).DATA(:, COL_DATA_C1C) = NST(k).DATA(:, COL_DATA_C1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
%         NST(k).DATA(:, COL_DATA_L1C) = NST(k).DATA(:, COL_DATA_L1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
        
    case MODEL_DLV3_PP_mat02
        if (mat_count(k) == 0) || (mat_count(k) == mat_count_max)       % ó�� ���۰� ���� epoch ������ ���� ����
            mat_file_count(k) = mat_file_count(k) + 1;
            mat_file_name = ['.\DATA_FILES\RAW_2008081215\test_2008081215_', num2str(k, '%.2i'), '_', num2str(mat_file_count(k), '%.3i'), '.mat'];
            load(mat_file_name);
            
            mat_count(k) = 0;
            mat_row = size(mat_data_1, 1);          % ������ ������ ���� ��� ũ�Ⱑ �ٸ� �� �����Ƿ� üũ
            mat_data(1:mat_row, k) = mat_data_1;
        end
        
        mat_count(k) = mat_count(k) + 1;            % ������ ����
        NST(k).EPOCH = mat_data(mat_count(k), k).EPOCH;
        NST(k).DATA = mat_data(mat_count(k), k).DATA;
        if isempty(NST(k).BufferEPH)
            NST(k).BufferEPH = mat_data(mat_count(k), k).BufferEPH;                     % �˵��� ������ ��ġ �κ��� ����Ǵ� ���, ������ �� ����
        else
            NST(k).BufferEPH = [NST(k).BufferEPH; mat_data(mat_count(k), k).BufferEPH]; % �˵��� ������ ��ġ �κ��� ����Ǵ� ���, ������ �� ����
        end
        
        if mat_data(mat_count(k), k).FileEnd == 1   % ���� üũ
            FileEnd(k) = 1;
        end
        
        % �Ʒ� ����ġ�� calSVsPos���� ��갪���� �����
%         % SV clock correction <- ���� Ephemeris �����Ϳ����� ����ġ�� �� �� ��ü
%         % OEMV Family Firmware Reference Manual�� SVXYZ ���� �� ����ġ ���� ����(512��, revision 5)
%         NST(k).DATA(:, COL_DATA_C1C) = NST(k).DATA(:, COL_DATA_C1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
%         NST(k).DATA(:, COL_DATA_L1C) = NST(k).DATA(:, COL_DATA_L1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
        
    case MODEL_DLV3_PP_mat03    % 20081010_1
        if (mat_count(k) == 0) || (mat_count(k) == mat_count_max)       % ó�� ���۰� ���� epoch ������ ���� ����
            mat_file_count(k) = mat_file_count(k) + 1;
            mat_file_name = ['.\DATA_FILES\RAW_20081010\test_20081010_1_', num2str(k, '%.2i'), '_', num2str(mat_file_count(k), '%.3i'), '.mat'];
            load(mat_file_name);
            
            mat_count(k) = 0;
            mat_row = size(mat_data_1, 1);          % ������ ������ ���� ��� ũ�Ⱑ �ٸ� �� �����Ƿ� üũ
            mat_data(1:mat_row, k) = mat_data_1;
        end
        
        mat_count(k) = mat_count(k) + 1;            % ������ ����
        NST(k).EPOCH = mat_data(mat_count(k), k).EPOCH;
        NST(k).DATA = mat_data(mat_count(k), k).DATA;
        if isempty(NST(k).BufferEPH)
            NST(k).BufferEPH = mat_data(mat_count(k), k).BufferEPH;                     % �˵��� ������ ��ġ �κ��� ����Ǵ� ���, ������ �� ����
        else
            NST(k).BufferEPH = [NST(k).BufferEPH; mat_data(mat_count(k), k).BufferEPH]; % �˵��� ������ ��ġ �κ��� ����Ǵ� ���, ������ �� ����
        end
        
        if mat_data(mat_count(k), k).FileEnd == 1   % ���� üũ
            FileEnd(k) = 1;
        end
        
        % �Ʒ� ����ġ�� calSVsPos���� ��갪���� �����
%         % SV clock correction <- ���� Ephemeris �����Ϳ����� ����ġ�� �� �� ��ü
%         % OEMV Family Firmware Reference Manual�� SVXYZ ���� �� ����ġ ���� ����(512��, revision 5)
%         NST(k).DATA(:, COL_DATA_C1C) = NST(k).DATA(:, COL_DATA_C1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);% + NST(k).DATA(:, COL_DATA_IonCorr) + NST(k).DATA(:, COL_DATA_TropoCorr);
%         NST(k).DATA(:, COL_DATA_L1C) = NST(k).DATA(:, COL_DATA_L1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);% + NST(k).DATA(:, COL_DATA_IonCorr) + NST(k).DATA(:, COL_DATA_TropoCorr);
        
    case MODEL_DLV3_PP_mat04    % 20081010_2
        if (mat_count(k) == 0) || (mat_count(k) == mat_count_max)       % ó�� ���۰� ���� epoch ������ ���� ����
            mat_file_count(k) = mat_file_count(k) + 1;
            mat_file_name = ['.\DATA_FILES\RAW_20081010\test_20081010_2_', num2str(k, '%.2i'), '_', num2str(mat_file_count(k), '%.3i'), '.mat'];
            load(mat_file_name);
            
            mat_count(k) = 0;
            mat_row = size(mat_data_1, 1);          % ������ ������ ���� ��� ũ�Ⱑ �ٸ� �� �����Ƿ� üũ
            mat_data(1:mat_row, k) = mat_data_1;
        end
        
        mat_count(k) = mat_count(k) + 1;            % ������ ����
        NST(k).EPOCH = mat_data(mat_count(k), k).EPOCH;
        NST(k).DATA = mat_data(mat_count(k), k).DATA;
        if isempty(NST(k).BufferEPH)
            NST(k).BufferEPH = mat_data(mat_count(k), k).BufferEPH;                     % �˵��� ������ ��ġ �κ��� ����Ǵ� ���, ������ �� ����
        else
            NST(k).BufferEPH = [NST(k).BufferEPH; mat_data(mat_count(k), k).BufferEPH]; % �˵��� ������ ��ġ �κ��� ����Ǵ� ���, ������ �� ����
        end
        
        if mat_data(mat_count(k), k).FileEnd == 1   % ���� üũ
            FileEnd(k) = 1;
        end
        
        % �Ʒ� ����ġ�� calSVsPos���� ��갪���� �����
%         % SV clock correction <- ���� Ephemeris �����Ϳ����� ����ġ�� �� �� ��ü
%         % OEMV Family Firmware Reference Manual�� SVXYZ ���� �� ����ġ ���� ����(512��, revision 5)
%         NST(k).DATA(:, COL_DATA_C1C) = NST(k).DATA(:, COL_DATA_C1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
%         NST(k).DATA(:, COL_DATA_L1C) = NST(k).DATA(:, COL_DATA_L1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
        
    case MODEL_DLV3_PP_mat05    % 20080623
        if (mat_count(k) == 0) || (mat_count(k) == mat_count_max)       % ó�� ���۰� ���� epoch ������ ���� ����
            mat_file_count(k) = mat_file_count(k) + 1;
            mat_file_name = ['.\DATA_FILES\RAW_20080623\test_20080623_', num2str(k, '%.2i'), '_', num2str(mat_file_count(k), '%.3i'), '.mat'];
            load(mat_file_name);
            
            mat_count(k) = 0;
            mat_row = size(mat_data_1, 1);          % ������ ������ ���� ��� ũ�Ⱑ �ٸ� �� �����Ƿ� üũ
            mat_data(1:mat_row, k) = mat_data_1;
        end
        
        mat_count(k) = mat_count(k) + 1;            % ������ ����
        NST(k).EPOCH = mat_data(mat_count(k), k).EPOCH;
        NST(k).DATA = mat_data(mat_count(k), k).DATA;
        if isempty(NST(k).BufferEPH)
            NST(k).BufferEPH = mat_data(mat_count(k), k).BufferEPH;                     % �˵��� ������ ��ġ �κ��� ����Ǵ� ���, ������ �� ����
        else
            NST(k).BufferEPH = [NST(k).BufferEPH; mat_data(mat_count(k), k).BufferEPH]; % �˵��� ������ ��ġ �κ��� ����Ǵ� ���, ������ �� ����
        end
        
        if mat_data(mat_count(k), k).FileEnd == 1   % ���� üũ
            FileEnd(k) = 1;
        end
        
        % �Ʒ� ����ġ�� calSVsPos���� ��갪���� �����
%         % SV clock correction <- ���� Ephemeris �����Ϳ����� ����ġ�� �� �� ��ü
%         % OEMV Family Firmware Reference Manual�� SVXYZ ���� �� ����ġ ���� ����(512��, revision 5)
%         NST(k).DATA(:, COL_DATA_C1C) = NST(k).DATA(:, COL_DATA_C1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
%         NST(k).DATA(:, COL_DATA_L1C) = NST(k).DATA(:, COL_DATA_L1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
        
%   case MODEL_DLV3_RTK
%         NST(k) = read_NovAtel_serial(NST(k));
%   case MODEL_SF2030M_PP
%         NST(k) = read_NavCom(NST(k));
%   case MODEL_RINEX
%         NST(k) = read_RINEX(NST(k));
        
    otherwise
        error('�̤�');
end

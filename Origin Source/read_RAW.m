%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read raw data                                  %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch NST(k).CONF.MODEL
    case MODEL_DLV3_PP
        [NST(k).EPOCH, NST(k).DATA, NST(k).BufferEPH, FileEnd(k)] = read_NovAtel(NST(k).FID, NST(k).EPOCH, NST(k).BufferEPH);
        % 주의: 현재 구문에서 읽은 Raw DATA를 변형하는 경우(예, 보정치 적용), 바로 다음 함수에서 실행되는 mat 저장하는 부분에 영향이 있음
        
        % 아래 보정치는 calSVsPos에서 계산값으로 적용됨
%         % SV clock correction <- 추후 Ephemeris 데이터에서의 보정치와 비교 후 대체
%         % OEMV Family Firmware Reference Manual의 SVXYZ 내용 중 보정치 내용 참조(512쪽, revision 5)
%         NST(k).DATA(:, COL_DATA_C1C) = NST(k).DATA(:, COL_DATA_C1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
%         NST(k).DATA(:, COL_DATA_L1C) = NST(k).DATA(:, COL_DATA_L1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
        
    case MODEL_DLV3_PP_mat01
        if (mat_count(k) == 0) || (mat_count(k) == mat_count_max)       % 처음 시작과 지정 epoch 수에서 파일 읽음
            mat_file_count(k) = mat_file_count(k) + 1;
            mat_file_name = ['.\DATA_FILES\RAW_2008070910\test_2008070910_', num2str(k, '%.2i'), '_', num2str(mat_file_count(k), '%.3i'), '.mat'];
            load(mat_file_name);
            
            mat_count(k) = 0;
            mat_row = size(mat_data_1, 1);          % 마지막 데이터 블럭의 경우 크기가 다를 수 있으므로 체크
            mat_data(1:mat_row, k) = mat_data_1;
        end
        
        mat_count(k) = mat_count(k) + 1;            % 데이터 저장
        NST(k).EPOCH = mat_data(mat_count(k), k).EPOCH;
        NST(k).DATA = mat_data(mat_count(k), k).DATA;
        if isempty(NST(k).BufferEPH)
            NST(k).BufferEPH = mat_data(mat_count(k), k).BufferEPH;                     % 궤도력 데이터 배치 부분이 변경되는 경우, 수정될 수 있음
        else
            NST(k).BufferEPH = [NST(k).BufferEPH; mat_data(mat_count(k), k).BufferEPH]; % 궤도력 데이터 배치 부분이 변경되는 경우, 수정될 수 있음
        end
        
        if mat_data(mat_count(k), k).FileEnd == 1   % 종료 체크
            FileEnd(k) = 1;
        end
        
        % 아래 보정치는 calSVsPos에서 계산값으로 적용됨
%         % SV clock correction <- 추후 Ephemeris 데이터에서의 보정치와 비교 후 대체
%         % OEMV Family Firmware Reference Manual의 SVXYZ 내용 중 보정치 내용 참조(512쪽, revision 5)
%         NST(k).DATA(:, COL_DATA_C1C) = NST(k).DATA(:, COL_DATA_C1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
%         NST(k).DATA(:, COL_DATA_L1C) = NST(k).DATA(:, COL_DATA_L1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
        
    case MODEL_DLV3_PP_mat02
        if (mat_count(k) == 0) || (mat_count(k) == mat_count_max)       % 처음 시작과 지정 epoch 수에서 파일 읽음
            mat_file_count(k) = mat_file_count(k) + 1;
            mat_file_name = ['.\DATA_FILES\RAW_2008081215\test_2008081215_', num2str(k, '%.2i'), '_', num2str(mat_file_count(k), '%.3i'), '.mat'];
            load(mat_file_name);
            
            mat_count(k) = 0;
            mat_row = size(mat_data_1, 1);          % 마지막 데이터 블럭의 경우 크기가 다를 수 있으므로 체크
            mat_data(1:mat_row, k) = mat_data_1;
        end
        
        mat_count(k) = mat_count(k) + 1;            % 데이터 저장
        NST(k).EPOCH = mat_data(mat_count(k), k).EPOCH;
        NST(k).DATA = mat_data(mat_count(k), k).DATA;
        if isempty(NST(k).BufferEPH)
            NST(k).BufferEPH = mat_data(mat_count(k), k).BufferEPH;                     % 궤도력 데이터 배치 부분이 변경되는 경우, 수정될 수 있음
        else
            NST(k).BufferEPH = [NST(k).BufferEPH; mat_data(mat_count(k), k).BufferEPH]; % 궤도력 데이터 배치 부분이 변경되는 경우, 수정될 수 있음
        end
        
        if mat_data(mat_count(k), k).FileEnd == 1   % 종료 체크
            FileEnd(k) = 1;
        end
        
        % 아래 보정치는 calSVsPos에서 계산값으로 적용됨
%         % SV clock correction <- 추후 Ephemeris 데이터에서의 보정치와 비교 후 대체
%         % OEMV Family Firmware Reference Manual의 SVXYZ 내용 중 보정치 내용 참조(512쪽, revision 5)
%         NST(k).DATA(:, COL_DATA_C1C) = NST(k).DATA(:, COL_DATA_C1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
%         NST(k).DATA(:, COL_DATA_L1C) = NST(k).DATA(:, COL_DATA_L1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
        
    case MODEL_DLV3_PP_mat03    % 20081010_1
        if (mat_count(k) == 0) || (mat_count(k) == mat_count_max)       % 처음 시작과 지정 epoch 수에서 파일 읽음
            mat_file_count(k) = mat_file_count(k) + 1;
            mat_file_name = ['.\DATA_FILES\RAW_20081010\test_20081010_1_', num2str(k, '%.2i'), '_', num2str(mat_file_count(k), '%.3i'), '.mat'];
            load(mat_file_name);
            
            mat_count(k) = 0;
            mat_row = size(mat_data_1, 1);          % 마지막 데이터 블럭의 경우 크기가 다를 수 있으므로 체크
            mat_data(1:mat_row, k) = mat_data_1;
        end
        
        mat_count(k) = mat_count(k) + 1;            % 데이터 저장
        NST(k).EPOCH = mat_data(mat_count(k), k).EPOCH;
        NST(k).DATA = mat_data(mat_count(k), k).DATA;
        if isempty(NST(k).BufferEPH)
            NST(k).BufferEPH = mat_data(mat_count(k), k).BufferEPH;                     % 궤도력 데이터 배치 부분이 변경되는 경우, 수정될 수 있음
        else
            NST(k).BufferEPH = [NST(k).BufferEPH; mat_data(mat_count(k), k).BufferEPH]; % 궤도력 데이터 배치 부분이 변경되는 경우, 수정될 수 있음
        end
        
        if mat_data(mat_count(k), k).FileEnd == 1   % 종료 체크
            FileEnd(k) = 1;
        end
        
        % 아래 보정치는 calSVsPos에서 계산값으로 적용됨
%         % SV clock correction <- 추후 Ephemeris 데이터에서의 보정치와 비교 후 대체
%         % OEMV Family Firmware Reference Manual의 SVXYZ 내용 중 보정치 내용 참조(512쪽, revision 5)
%         NST(k).DATA(:, COL_DATA_C1C) = NST(k).DATA(:, COL_DATA_C1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);% + NST(k).DATA(:, COL_DATA_IonCorr) + NST(k).DATA(:, COL_DATA_TropoCorr);
%         NST(k).DATA(:, COL_DATA_L1C) = NST(k).DATA(:, COL_DATA_L1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);% + NST(k).DATA(:, COL_DATA_IonCorr) + NST(k).DATA(:, COL_DATA_TropoCorr);
        
    case MODEL_DLV3_PP_mat04    % 20081010_2
        if (mat_count(k) == 0) || (mat_count(k) == mat_count_max)       % 처음 시작과 지정 epoch 수에서 파일 읽음
            mat_file_count(k) = mat_file_count(k) + 1;
            mat_file_name = ['.\DATA_FILES\RAW_20081010\test_20081010_2_', num2str(k, '%.2i'), '_', num2str(mat_file_count(k), '%.3i'), '.mat'];
            load(mat_file_name);
            
            mat_count(k) = 0;
            mat_row = size(mat_data_1, 1);          % 마지막 데이터 블럭의 경우 크기가 다를 수 있으므로 체크
            mat_data(1:mat_row, k) = mat_data_1;
        end
        
        mat_count(k) = mat_count(k) + 1;            % 데이터 저장
        NST(k).EPOCH = mat_data(mat_count(k), k).EPOCH;
        NST(k).DATA = mat_data(mat_count(k), k).DATA;
        if isempty(NST(k).BufferEPH)
            NST(k).BufferEPH = mat_data(mat_count(k), k).BufferEPH;                     % 궤도력 데이터 배치 부분이 변경되는 경우, 수정될 수 있음
        else
            NST(k).BufferEPH = [NST(k).BufferEPH; mat_data(mat_count(k), k).BufferEPH]; % 궤도력 데이터 배치 부분이 변경되는 경우, 수정될 수 있음
        end
        
        if mat_data(mat_count(k), k).FileEnd == 1   % 종료 체크
            FileEnd(k) = 1;
        end
        
        % 아래 보정치는 calSVsPos에서 계산값으로 적용됨
%         % SV clock correction <- 추후 Ephemeris 데이터에서의 보정치와 비교 후 대체
%         % OEMV Family Firmware Reference Manual의 SVXYZ 내용 중 보정치 내용 참조(512쪽, revision 5)
%         NST(k).DATA(:, COL_DATA_C1C) = NST(k).DATA(:, COL_DATA_C1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
%         NST(k).DATA(:, COL_DATA_L1C) = NST(k).DATA(:, COL_DATA_L1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
        
    case MODEL_DLV3_PP_mat05    % 20080623
        if (mat_count(k) == 0) || (mat_count(k) == mat_count_max)       % 처음 시작과 지정 epoch 수에서 파일 읽음
            mat_file_count(k) = mat_file_count(k) + 1;
            mat_file_name = ['.\DATA_FILES\RAW_20080623\test_20080623_', num2str(k, '%.2i'), '_', num2str(mat_file_count(k), '%.3i'), '.mat'];
            load(mat_file_name);
            
            mat_count(k) = 0;
            mat_row = size(mat_data_1, 1);          % 마지막 데이터 블럭의 경우 크기가 다를 수 있으므로 체크
            mat_data(1:mat_row, k) = mat_data_1;
        end
        
        mat_count(k) = mat_count(k) + 1;            % 데이터 저장
        NST(k).EPOCH = mat_data(mat_count(k), k).EPOCH;
        NST(k).DATA = mat_data(mat_count(k), k).DATA;
        if isempty(NST(k).BufferEPH)
            NST(k).BufferEPH = mat_data(mat_count(k), k).BufferEPH;                     % 궤도력 데이터 배치 부분이 변경되는 경우, 수정될 수 있음
        else
            NST(k).BufferEPH = [NST(k).BufferEPH; mat_data(mat_count(k), k).BufferEPH]; % 궤도력 데이터 배치 부분이 변경되는 경우, 수정될 수 있음
        end
        
        if mat_data(mat_count(k), k).FileEnd == 1   % 종료 체크
            FileEnd(k) = 1;
        end
        
        % 아래 보정치는 calSVsPos에서 계산값으로 적용됨
%         % SV clock correction <- 추후 Ephemeris 데이터에서의 보정치와 비교 후 대체
%         % OEMV Family Firmware Reference Manual의 SVXYZ 내용 중 보정치 내용 참조(512쪽, revision 5)
%         NST(k).DATA(:, COL_DATA_C1C) = NST(k).DATA(:, COL_DATA_C1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
%         NST(k).DATA(:, COL_DATA_L1C) = NST(k).DATA(:, COL_DATA_L1C) + NST(k).DATA(:, COL_DATA_SVClkCorr);
        
%   case MODEL_DLV3_RTK
%         NST(k) = read_NovAtel_serial(NST(k));
%   case MODEL_SF2030M_PP
%         NST(k) = read_NavCom(NST(k));
%   case MODEL_RINEX
%         NST(k) = read_RINEX(NST(k));
        
    otherwise
        error('ㅜㅜ');
end

% Raw Data의 mat 파일 저장(option) : MODEL_DLV3_PP_matXX 모드 동작을 위한 저장
if NST(k).EPOCH.GPSTIME == NPS.GPSTIME
    mat_count(k) = mat_count(k) + 1;            % 데이터 저장
    disp([mat_count(1), mat_count(2)]);
    mat_data(mat_count(k), k).EPOCH = NST(k).EPOCH;
    mat_data(mat_count(k), k).DATA = NST(k).DATA;
    mat_data(mat_count(k), k).BufferEPH = NST(k).BufferEPH; % 궤도력 데이터 배치 부분이 변경되는 경우, 수정될 수 있음
end

if NPS.COUNT == EoE-1, FileEnd(k) = 1; end  % 수동 종료 변수 체크(파일 끝으로 인식)
% 사용자 파일이 끝나는 시점이 프로그램 끝나는 시점으로 설정인 경우의 추가 부분
% (k=1이 사용자인 경우를 가정, FileEnd(k)가 1인 경우는 이 함수(read_RAW)를 실행하지 않음)
if FileEnd(1) && (FileEnd(k) == 0), FileEnd(k) = 1; end

if FileEnd(k) == 1                          % 파일 종료 전의 저장
    mat_data(mat_count(k), k).FileEnd = 1;  % 종료 변수 저장(1: 파일 끝)
    FileEnd(k) = 2;                         % 마지막 파일 저장은 한 번한 하기 위한 처리
    
    mat_file_count(k) = mat_file_count(k) + 1;
    mat_file_name = ['.\DATA_FILES\RAW_20080709XX\test_20080709XX_', num2str(k, '%.2i'), '_', num2str(mat_file_count(k), '%.3i'), '.mat'];
%     mat_file_name = ['.\DATA_FILES\RAW_20080623\test_20080623_', num2str(k, '%.2i'), '_', num2str(mat_file_count(k), '%.3i'), '.mat'];
    
    mat_data_1 = mat_data(:, k);
    save(mat_file_name, '-v6', 'mat_data_1');
elseif NST(k).EPOCH.GPSTIME == NPS.GPSTIME
    mat_data(mat_count(k), k).FileEnd = 0;  % 종료 변수 저장
    
    if mat_count(k) == mat_count_max        % 지정 epoch 수에서 파일로 분리 저장
        mat_file_count(k) = mat_file_count(k) + 1;
        mat_file_name = ['.\DATA_FILES\RAW_20080709XX\test_20080709XX_', num2str(k, '%.2i'), '_', num2str(mat_file_count(k), '%.3i'), '.mat'];
%         mat_file_name = ['.\DATA_FILES\RAW_20080623\test_20080623_', num2str(k, '%.2i'), '_', num2str(mat_file_count(k), '%.3i'), '.mat'];
        
        mat_data_1 = mat_data(:, k);
        save(mat_file_name, '-v6', 'mat_data_1');
        
        mat_count(k) = 0;
    end
end

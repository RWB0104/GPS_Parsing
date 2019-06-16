% Raw Data�� mat ���� ����(option) : MODEL_DLV3_PP_matXX ��� ������ ���� ����
if NST(k).EPOCH.GPSTIME == NPS.GPSTIME
    mat_count(k) = mat_count(k) + 1;            % ������ ����
    disp([mat_count(1), mat_count(2)]);
    mat_data(mat_count(k), k).EPOCH = NST(k).EPOCH;
    mat_data(mat_count(k), k).DATA = NST(k).DATA;
    mat_data(mat_count(k), k).BufferEPH = NST(k).BufferEPH; % �˵��� ������ ��ġ �κ��� ����Ǵ� ���, ������ �� ����
end

if NPS.COUNT == EoE-1, FileEnd(k) = 1; end  % ���� ���� ���� üũ(���� ������ �ν�)
% ����� ������ ������ ������ ���α׷� ������ �������� ������ ����� �߰� �κ�
% (k=1�� ������� ��츦 ����, FileEnd(k)�� 1�� ���� �� �Լ�(read_RAW)�� �������� ����)
if FileEnd(1) && (FileEnd(k) == 0), FileEnd(k) = 1; end

if FileEnd(k) == 1                          % ���� ���� ���� ����
    mat_data(mat_count(k), k).FileEnd = 1;  % ���� ���� ����(1: ���� ��)
    FileEnd(k) = 2;                         % ������ ���� ������ �� ���� �ϱ� ���� ó��
    
    mat_file_count(k) = mat_file_count(k) + 1;
    mat_file_name = ['.\DATA_FILES\RAW_20080709XX\test_20080709XX_', num2str(k, '%.2i'), '_', num2str(mat_file_count(k), '%.3i'), '.mat'];
%     mat_file_name = ['.\DATA_FILES\RAW_20080623\test_20080623_', num2str(k, '%.2i'), '_', num2str(mat_file_count(k), '%.3i'), '.mat'];
    
    mat_data_1 = mat_data(:, k);
    save(mat_file_name, '-v6', 'mat_data_1');
elseif NST(k).EPOCH.GPSTIME == NPS.GPSTIME
    mat_data(mat_count(k), k).FileEnd = 0;  % ���� ���� ����
    
    if mat_count(k) == mat_count_max        % ���� epoch ������ ���Ϸ� �и� ����
        mat_file_count(k) = mat_file_count(k) + 1;
        mat_file_name = ['.\DATA_FILES\RAW_20080709XX\test_20080709XX_', num2str(k, '%.2i'), '_', num2str(mat_file_count(k), '%.3i'), '.mat'];
%         mat_file_name = ['.\DATA_FILES\RAW_20080623\test_20080623_', num2str(k, '%.2i'), '_', num2str(mat_file_count(k), '%.3i'), '.mat'];
        
        mat_data_1 = mat_data(:, k);
        save(mat_file_name, '-v6', 'mat_data_1');
        
        mat_count(k) = 0;
    end
end

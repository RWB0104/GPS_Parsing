%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Nhat, P] = rearrangeAmbiguity(Nhat, P, NPS, BackupNPS, DATA_usr, DATA_ref, var_C1C_SD)

global COL_DATA_C1C COL_DATA_L1C

% ó�� ������ ��� <- ���� �� �κ��� �ʿ������ ���α׷� ����
if isempty(P)
    P = var_C1C_SD;
    Nhat = (DATA_usr(:,COL_DATA_L1C) - DATA_usr(:,COL_DATA_C1C)) - (DATA_ref(:,COL_DATA_L1C) - DATA_ref(:,COL_DATA_C1C));
    return;
end

% �ӽ� ���� �ʱ�ȭ
temp_P = zeros(NPS.NoSVc, NPS.NoSVc);
temp_Nhat = Nhat;
Nhat = zeros(NPS.NoSVc, 1);
temp01 = cell(NPS.NoSVc, 1);

% P�� �� �κ� ����
for k=1:NPS.NoSVc
    temp01{k} = find(BackupNPS{NPS.IoB}.PRNc == NPS.PRNc(k), 1);
    if ~isempty(temp01{k})
        temp_P(k,1:BackupNPS{NPS.IoB}.NoSVc) = P(temp01{k},1:BackupNPS{NPS.IoB}.NoSVc);
    end
end

% P�� �� �κа� N ����
P = zeros(NPS.NoSVc, NPS.NoSVc);
for k=NPS.NoSVc:-1:1
    if ~isempty(temp01{k})
        P(:, k) = temp_P(:, temp01{k});
        Nhat(k) = temp_Nhat(temp01{k});
%     elseif % Lock time �ð� ��
%            % Lock time�� ������ ���� ���(��� ���� ������), ���� ��� �����Ͱ� �ִ� ���� �� ������ ���
    else    % ���ο� ���� ���� ������ �ʱ�ȭ
        P(k, k) = var_C1C_SD(k, k);
        Nhat(k) = (DATA_usr(k,COL_DATA_L1C) - DATA_usr(k,COL_DATA_C1C)) - (DATA_ref(k,COL_DATA_L1C) - DATA_ref(k,COL_DATA_C1C));
    end
end

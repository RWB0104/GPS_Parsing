%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Nhat, P] = rearrangeAmbiguity(Nhat, P, NPS, BackupNPS, DATA_usr, DATA_ref, var_C1C_SD)

global COL_DATA_C1C COL_DATA_L1C

% 처음 시작인 경우 <- 추후 이 부분이 필요없도록 프로그램 수정
if isempty(P)
    P = var_C1C_SD;
    Nhat = (DATA_usr(:,COL_DATA_L1C) - DATA_usr(:,COL_DATA_C1C)) - (DATA_ref(:,COL_DATA_L1C) - DATA_ref(:,COL_DATA_C1C));
    return;
end

% 임시 변수 초기화
temp_P = zeros(NPS.NoSVc, NPS.NoSVc);
temp_Nhat = Nhat;
Nhat = zeros(NPS.NoSVc, 1);
temp01 = cell(NPS.NoSVc, 1);

% P의 행 부분 정렬
for k=1:NPS.NoSVc
    temp01{k} = find(BackupNPS{NPS.IoB}.PRNc == NPS.PRNc(k), 1);
    if ~isempty(temp01{k})
        temp_P(k,1:BackupNPS{NPS.IoB}.NoSVc) = P(temp01{k},1:BackupNPS{NPS.IoB}.NoSVc);
    end
end

% P의 열 부분과 N 정렬
P = zeros(NPS.NoSVc, NPS.NoSVc);
for k=NPS.NoSVc:-1:1
    if ~isempty(temp01{k})
        P(:, k) = temp_P(:, temp01{k});
        Nhat(k) = temp_Nhat(temp01{k});
%     elseif % Lock time 시간 안
%            % Lock time이 끊기지 않은 경우(통신 등의 문제로), 안의 백업 데이터가 있는 경우는 그 데이터 사용
    else    % 새로운 위성 관련 데이터 초기화
        P(k, k) = var_C1C_SD(k, k);
        Nhat(k) = (DATA_usr(k,COL_DATA_L1C) - DATA_usr(k,COL_DATA_C1C)) - (DATA_ref(k,COL_DATA_L1C) - DATA_ref(k,COL_DATA_C1C));
    end
end

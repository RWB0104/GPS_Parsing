%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% smoothing                                      %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [DATA, preSmoothing] = smoothing(TIME, TIMESTEP, DATA, preSmoothing, ManualReset)

global COL_DATA_PRN COL_DATA_C1C COL_DATA_L1C COL_DATA_C1Cs COL_DATA_C1Cs_Count
global COL_pSD_GPSTIME COL_pSD_C1Cs COL_pSD_C1Cs_Count COL_pSD_L1C
global CONST_Tau_d

CountMax = round(CONST_Tau_d / TIMESTEP);

temp01 = size(DATA, 1);         % 측정 위성수
if nargin < 5, ManualReset = zeros(temp01, 1); end      % 다른 테스트에 의한 리셋 입력값이 없는 경우의 설정
for k=1:temp01
    if ManualReset(k)           % 다른 테스트에 의한 리셋인 경우
        DATA(k, COL_DATA_C1Cs) = DATA(:, COL_DATA_C1C);
        DATA(k, COL_DATA_C1Cs_Count) = 1;
    else
        % 스무딩 계산
        PRN = DATA(k,COL_DATA_PRN);
        temp02 = TIME - preSmoothing(DATA(k,COL_DATA_PRN), COL_pSD_GPSTIME);
        if preSmoothing(PRN, COL_pSD_C1Cs_Count) == CountMax
            temp03 = 1;         % 스무딩 카운터 최대값 체크
            temp04 = CountMax;  % 스무딩 카운터
        else
            temp03 = 0;
            temp04 = preSmoothing(DATA(k,COL_DATA_PRN), COL_pSD_C1Cs_Count) + 1;
        end
        if temp02 == TIMESTEP                           % 전 에폭 데이터가 있는 경우
            temp05 = 1/temp04;
            DATA(k, COL_DATA_C1Cs) = temp05*DATA(k, COL_DATA_C1C) + (1-temp05)*(preSmoothing(PRN, COL_pSD_C1Cs) + DATA(k, COL_DATA_L1C) - preSmoothing(PRN, COL_pSD_L1C));
            DATA(k, COL_DATA_C1Cs_Count) = temp04;
        elseif (temp02 == TIMESTEP*2) && temp03         % 스무딩 최대값에 전전 에폭 데이터가 있는 경우(1 에폭 끊긴 경우)
            temp05 = 1/(round(CONST_Tau_d / TIMESTEP*2));
            DATA(k, COL_DATA_C1Cs) = temp05*DATA(k, COL_DATA_C1C) + (1-temp05)*(preSmoothing(PRN, COL_pSD_C1Cs) + DATA(k, COL_DATA_L1C) - preSmoothing(PRN, COL_pSD_L1C));
            DATA(k, COL_DATA_C1Cs_Count) = CountMax;
        elseif (temp02 == TIMESTEP*3) && temp03         % 스무딩 최대값에 전전전 에폭 데이터가 있는 경우(2 에폭 끊긴 경우)
            temp05 = 1/(round(CONST_Tau_d / TIMESTEP*3));
            DATA(k, COL_DATA_C1Cs) = temp05*DATA(k, COL_DATA_C1C) + (1-temp05)*(preSmoothing(PRN, COL_pSD_C1Cs) + DATA(k, COL_DATA_L1C) - preSmoothing(PRN, COL_pSD_L1C));
            DATA(k, COL_DATA_C1Cs_Count) = CountMax;
        else                                            % 그 외
            DATA(k, COL_DATA_C1Cs) = DATA(k, COL_DATA_C1C);
            DATA(k, COL_DATA_C1Cs_Count) = 1;
        end
    end
    
    % 스무딩 백업
    preSmoothing(PRN, COL_pSD_GPSTIME) = TIME;
    preSmoothing(PRN, COL_pSD_C1Cs) = DATA(k, COL_DATA_C1Cs);
    preSmoothing(PRN, COL_pSD_C1Cs_Count) = DATA(k, COL_DATA_C1Cs_Count);
    preSmoothing(PRN, COL_pSD_L1C) = DATA(k, COL_DATA_L1C);
end

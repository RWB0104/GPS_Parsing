%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SVs xyz (ecef)                                 %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



for k1=1:size(NST(k).DATA, 1)
    
    
    NST(k).DATA(k1, COL_DATA_SVXYZ) = zeros(1,3);
    
    tempPRN = NST(k).DATA(k1, COL_DATA_PRN);
    if tempPRN > CONST_GPS_PRNmax, continue; end                % GPS 위성 체크(GPS 위성 외 계산 내용이 추가 될 경우 조건문으로 선별 계산으로 수정 필요)
    
    del_t_tr = NST(k).DATA(k1, COL_DATA_C1C) / CONST_C;
    tc = NST(k).EPOCH.GPSSECOND - del_t_tr;                     % Transmission time
    temp21 = 0;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(NPS.EPH(tempPRN,NPS.IoE).PRN)                   % 현 시간대 궤도력 데이터가 있는 경우
        temp21 = 1;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [NST(k).DATA(k1, COL_DATA_SVXYZ), del_t_SV] = SVPos(NPS.EPH(tempPRN, NPS.IoE), tc, del_t_tr);
        
        % 
        del_t_SV_L1 = del_t_SV - NPS.EPH(tempPRN, NPS.IoE).TGD;
        NST(k).DATA(k1, COL_DATA_C1C) = NST(k).DATA(k1, COL_DATA_C1C) + CONST_C*(del_t_SV_L1);
        NST(k).DATA(k1, COL_DATA_L1C) = NST(k).DATA(k1, COL_DATA_L1C) + CONST_C*(del_t_SV_L1);
%         disp([tempPRN, NST(k).DATA(k1, COL_DATA_SVClkCorr), CONST_C*del_t_SV_L1, CONST_C*del_t_SV]);    % 결과: COL_DATA_SVClkCorr == del_t_SV
        gamma = (77/60)^2;% = (CONST_F1/CONST_F2)^2;
        del_t_SV_L2 = del_t_SV - gamma*NPS.EPH(tempPRN, NPS.IoE).TGD;
        NST(k).DATA(k1, COL_DATA_C2W) = NST(k).DATA(k1, COL_DATA_C2W) + CONST_C*(del_t_SV_L2);
        NST(k).DATA(k1, COL_DATA_L2W) = NST(k).DATA(k1, COL_DATA_L2W) + CONST_C*(del_t_SV_L2);
    else                                                        % 다음 시간대 궤도력 데이터가 있는 경우
        temp21 = 2;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if NPS.IoE == NoE
            if ~isempty(NPS.EPH(tempPRN,1).PRN)
                [NST(k).DATA(k1, COL_DATA_SVXYZ), del_t_SV] = SVPos(NPS.EPH(tempPRN, 1), tc, del_t_tr);
                
                % 
                del_t_SV_L1 = del_t_SV - NPS.EPH(tempPRN, 1).TGD;
                NST(k).DATA(k1, COL_DATA_C1C) = NST(k).DATA(k1, COL_DATA_C1C) + CONST_C*(del_t_SV_L1);
                NST(k).DATA(k1, COL_DATA_L1C) = NST(k).DATA(k1, COL_DATA_L1C) + CONST_C*(del_t_SV_L1);
%                 disp([tempPRN, NST(k).DATA(k1, COL_DATA_SVClkCorr), CONST_C*del_t_SV_L1, CONST_C*del_t_SV]);
                gamma = (77/60)^2;% = (CONST_F1/CONST_F2)^2;
                del_t_SV_L2 = del_t_SV - gamma*NPS.EPH(tempPRN, 1).TGD;
                NST(k).DATA(k1, COL_DATA_C2W) = NST(k).DATA(k1, COL_DATA_C2W) + CONST_C*(del_t_SV_L2);
                NST(k).DATA(k1, COL_DATA_L2W) = NST(k).DATA(k1, COL_DATA_L2W) + CONST_C*(del_t_SV_L2);
            end
        else
            if ~isempty(NPS.EPH(tempPRN,NPS.IoE+1).PRN)
                [NST(k).DATA(k1, COL_DATA_SVXYZ), del_t_SV] = SVPos(NPS.EPH(tempPRN, NPS.IoE+1), tc, del_t_tr);
                
                % 
                del_t_SV_L1 = del_t_SV - NPS.EPH(tempPRN, NPS.IoE+1).TGD;
                NST(k).DATA(k1, COL_DATA_C1C) = NST(k).DATA(k1, COL_DATA_C1C) + CONST_C*(del_t_SV_L1);
                NST(k).DATA(k1, COL_DATA_L1C) = NST(k).DATA(k1, COL_DATA_L1C) + CONST_C*(del_t_SV_L1);
%                 disp([tempPRN, NST(k).DATA(k1, COL_DATA_SVClkCorr), CONST_C*del_t_SV_L1, CONST_C*del_t_SV]);
                gamma = (77/60)^2;% = (CONST_F1/CONST_F2)^2;
                del_t_SV_L2 = del_t_SV - gamma*NPS.EPH(tempPRN, NPS.IoE+1).TGD;
                NST(k).DATA(k1, COL_DATA_C2W) = NST(k).DATA(k1, COL_DATA_C2W) + CONST_C*(del_t_SV_L2);
                NST(k).DATA(k1, COL_DATA_L2W) = NST(k).DATA(k1, COL_DATA_L2W) + CONST_C*(del_t_SV_L2);
            end
        end
    end
%     if NST(k).DATA(k1, COL_DATA_SVXYZ(1)) == 0, disp(['TIME: ', num2str(NST(k).EPOCH.GPSTIME, '%10.1f'), ',   PRN: ', num2str(tempPRN, '%3i'), '   <- No Ephemeris']); end
end

% 위성 위치 없는 데이터 삭제
del_PRN = find(NST(k).DATA(:, COL_DATA_SVXYZ(1)) == 0);
if(~isempty(del_PRN)), NST(k).DATA(del_PRN, :) = []; end

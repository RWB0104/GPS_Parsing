%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% decide filtering                               %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [FilteringTime, FilteringFlag] = decide_filtering(NPS, BackupNPS, FilteringTime, FilteringPeriod)

FilteringFlag = 0;

% 필터링 주기 체크
if (NPS.GPSTIME - FilteringTime) >= FilteringPeriod
    FilteringFlag = 1;
    FilteringTime = NPS.GPSTIME;
    return;
end

% 위성 변화 체크
if ~isequal(NPS.PRNc, BackupNPS{NPS.IoB}.PRNc)
    FilteringFlag = 1;
    FilteringTime = NPS.GPSTIME;
    return;
end

% 모드 변화 체크
if NPS.MODE ~= BackupNPS{NPS.IoB}.MODE
    FilteringFlag = 1;
    FilteringTime = NPS.GPSTIME;
    return;
end

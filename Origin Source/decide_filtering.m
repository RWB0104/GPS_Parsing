%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% decide filtering                               %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [FilteringTime, FilteringFlag] = decide_filtering(NPS, BackupNPS, FilteringTime, FilteringPeriod)

FilteringFlag = 0;

% ���͸� �ֱ� üũ
if (NPS.GPSTIME - FilteringTime) >= FilteringPeriod
    FilteringFlag = 1;
    FilteringTime = NPS.GPSTIME;
    return;
end

% ���� ��ȭ üũ
if ~isequal(NPS.PRNc, BackupNPS{NPS.IoB}.PRNc)
    FilteringFlag = 1;
    FilteringTime = NPS.GPSTIME;
    return;
end

% ��� ��ȭ üũ
if NPS.MODE ~= BackupNPS{NPS.IoB}.MODE
    FilteringFlag = 1;
    FilteringTime = NPS.GPSTIME;
    return;
end

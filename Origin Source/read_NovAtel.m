%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read NovAtel file (.gps, ascii)                %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [EPOCH, DATA, tempEPH, FileEnd] = read_NovAtel(FID, EPOCH, tempEPH)

global COL_DATA_PRN COL_DATA_C1C COL_DATA_C2W COL_DATA_L1C COL_DATA_L2W ...
       COL_DATA_D1C COL_DATA_D2W COL_DATA_S1C COL_DATA_S2W ...
       COL_DATA_L1_LockTime COL_DATA_L2_LockTime COL_DATA_SVXYZ ...
       COL_DATA_SVClkCorr COL_DATA_IonCorr COL_DATA_TropoCorr COL_DATA_MAX COL_DATA_INITNAN
global CONST_LAMBDA1 CONST_LAMBDA2

Min_time = zeros(3,3);
packet_data = cell(3, 1);
FileEnd = 0;

FID=fopen('test1_2008070910.gps');
%FID=fopen('KARI_2008082731.gps');


while 1
    if ~feof(FID)
        read_data = fgetl(FID);
    else
        fclose(FID);
        FileEnd = 1;
        break;
    end
    
    line_length = size(read_data, 2);
    
    remain = strread(read_data, '%s', 'delimiter', ',');

    time = str2double(remain{6})*604800 + str2double(remain{7});

    filled_col = find(Min_time(:, 1) ~= 0);
    
    if size(filled_col, 1) ~= 0
        if time > Min_time(filled_col(1), 1)
            fseek(FID, -(line_length+2), 'cof');
            break;
        end
    end

    switch remain{1}
        case '#RANGEA'
            Min_time(1, 1) = time;
            Min_time(1, 2) = str2double(remain{6});
            Min_time(1, 3) = str2double(remain{7});
            packet_data{1, 1} = read_data;
        case '#RAWEPHEMA'
            temp = read_RAWEPHEM_NovAtel(read_data);
            tempEPH = [tempEPH; temp];
        case '#BESTXYZA'
            Min_time(2, 1) = time;
            disp(time)
            Min_time(2, 2) = str2double(remain{6});
            Min_time(2, 3) = str2double(remain{7});
            packet_data{3, 1} = read_data;    
        case '#SATXYZA'
            Min_time(3, 1) = time;
            Min_time(3, 2) = str2double(remain{6});
            Min_time(3, 3) = str2double(remain{7});
            packet_data{2, 1} = read_data;
    end
end

EPOCH.FLAG = 0;
filled_col = find(Min_time(:, 1) ~= 0);

if size(filled_col, 1) ~= 0
    EPOCH.GPSTIME = Min_time(1, 1);
    EPOCH.GPSWEEK = Min_time(1, 2);
    EPOCH.GPSSECOND = Min_time(1, 3);
    UTC_TIME = gps2utc([mod(EPOCH.GPSWEEK, 1024) EPOCH.GPSSECOND]);
    disp(UTC_TIME)
    EPOCH.UTCYEAR = UTC_TIME(1);
    EPOCH.UTCMONTH = UTC_TIME(2);
    EPOCH.UTCDAY = UTC_TIME(3);
    EPOCH.UTCHOUR = UTC_TIME(4);
    EPOCH.UTCMINUTH = UTC_TIME(5);
    EPOCH.UTCSECOND = UTC_TIME(6);
end

[token, packet_data] = strtok(packet_data, ';');
packet_data = strrep(packet_data, ',', ' ');
packet_data = strrep(packet_data, ';', ' ');
packet_data = strrep(packet_data, '*', ' ');

Max_count = 0;
DATA = [];      %%%%%%%%%%

% RANGE
if Min_time(1, 1) ~= 0
    EPOCH.FLAG = EPOCH.FLAG + 1;
    % Range 로그에서 Pseudorange, Carrier phase, C/No, locktime 추출
    remain = strread(packet_data{1}, '%s');
    for k=1:str2double(remain{1})
        if k==1
            Max_count = Max_count + 1;
            DATA(Max_count, COL_DATA_INITNAN) = NaN(1, COL_DATA_MAX);
            DATA(Max_count, COL_DATA_PRN) = str2double(remain{10*(k-1)+2});
            current_pos = Max_count;
        else
            find_null = find(DATA(:, COL_DATA_PRN) == str2double(remain{10*(k-1)+2}));
            if(isempty(find_null))
                Max_count = Max_count + 1;
                DATA(Max_count, COL_DATA_INITNAN) = NaN(1, COL_DATA_MAX);
                DATA(Max_count, COL_DATA_PRN) = str2double(remain{10*(k-1)+2});
                current_pos = Max_count;
            else
                current_pos = find_null;
            end
        end
        
        Frequency_Type = bitget(hex2dec(remain{10*(k-1)+11}), 22);
        temp = bitget(hex2dec(remain{10*(k-1)+11}), 23)*2;
        Frequency_Type = Frequency_Type + temp;
        
        if Frequency_Type == 0
            DATA(current_pos, COL_DATA_C1C) = str2double(remain{10*(k-1)+4});
            DATA(current_pos, COL_DATA_L1C) = str2double(remain{10*(k-1)+6}) * -1 * CONST_LAMBDA1;
            DATA(current_pos, COL_DATA_D1C) = str2double(remain{10*(k-1)+8});   % Hz
            DATA(current_pos, COL_DATA_S1C) = str2double(remain{10*(k-1)+9});
            DATA(current_pos, COL_DATA_L1_LockTime) = str2double(remain{10*(k-1)+10});
        elseif Frequency_Type == 1
            DATA(current_pos, COL_DATA_C2W) = str2double(remain{10*(k-1)+4});
            DATA(current_pos, COL_DATA_L2W) = str2double(remain{10*(k-1)+6}) * -1 * CONST_LAMBDA2;
            DATA(current_pos, COL_DATA_D2W) = str2double(remain{10*(k-1)+8});   % Hz
            DATA(current_pos, COL_DATA_S2W) = str2double(remain{10*(k-1)+9});
            DATA(current_pos, COL_DATA_L2_LockTime) = str2double(remain{10*(k-1)+10});        
        end
    end
end

% BESTXYZ
if Min_time(2, 1) ~= 0
    EPOCH.FLAG = EPOCH.FLAG + 2;
    remain = strread(packet_data{3}, '%s');
    EPOCH.XYZB = [str2double(remain{3}), str2double(remain{4}), str2double(remain{5}), 0];
end

% SATXYZA
if Min_time(1, 1) ~= 0 && Min_time(3, 1) ~= 0
    EPOCH.FLAG = EPOCH.FLAG + 4;
    remain = strread(packet_data{2}, '%s');
    
    count = remain{2};
    
    for k=1:str2double(count)
        find_null = find(DATA(:, COL_DATA_PRN) == str2double(remain{9*(k-1)+3}));
        if(~isempty(find_null))
            current_pos = find_null;
            DATA(current_pos, COL_DATA_SVXYZ) = [str2double(remain{9*(k-1)+4}), str2double(remain{9*(k-1)+5}), str2double(remain{9*(k-1)+6})];
            
            DATA(current_pos, COL_DATA_SVClkCorr) = str2double(remain{9*(k-1)+7});  % SV clock correction
            DATA(current_pos, COL_DATA_IonCorr) = str2double(remain{9*(k-1)+8});    % ion corr
            DATA(current_pos, COL_DATA_TropoCorr) = str2double(remain{9*(k-1)+9});  % trop corr
        else
            Max_count = Max_count + 1;
            DATA(Max_count, COL_DATA_INITNAN) = NaN(1, COL_DATA_MAX);
            DATA(Max_count, COL_DATA_PRN) = str2double(remain{9*(k-1)+3});
            %DATA(Max_count, COL_DATA_SVXYZ) = [str2double(remain{9*(k-1)+4}), str2double(remain{9*(k-1)+5}), str2double(remain{9*(k-1)+6})];
            
            DATA(Max_count, COL_DATA_SVClkCorr) = str2double(remain{9*(k-1)+7});    % SV clock correction
            DATA(Max_count, COL_DATA_IonCorr) = str2double(remain{9*(k-1)+8});      % ion corr
            DATA(Max_count, COL_DATA_TropoCorr) = str2double(remain{9*(k-1)+9});    % trop corr
        end
    end
end

EPOCH.CLKOFFSET = NaN;              % 현재 데이터가 없으므로 값만 초기화(Not A Number)
EPOCH.NoSV = NaN; 

% 필수 데이터 확인(C1C, L1C, SVXYZ) <- 추후 수정 필요(SVXYZ의 궤도력 데이터를 이용하여 계산 후 등)
if ~isempty(DATA)
    temp = size(DATA, 1);
    for k=temp:-1:1
        if isnan(DATA(k, COL_DATA_C1C)) || isnan(DATA(k, COL_DATA_L1C))
            DATA(k, :) = [];
        end
        if isnan(DATA(k, COL_DATA_SVXYZ(1))) || isnan(DATA(k, COL_DATA_SVClkCorr))
%             if DATA(k, COL_DATA_PRN) < 33
%                 disp(['No SV position(', num2str(FID), ') : ', num2str(DATA(k, COL_DATA_PRN))]);
%             end
            DATA(k, :) = [];
        end
    end
end

% RANGE 데이터가 없는 경우 다음 에폭 읽음(해당 시간 체크는 read_RAW 함수 밖에서 하여 해당 시간의 데이터 유무 판단함)
%while isempty(DATA)
%    [EPOCH, DATA, tempEPH, FileEnd] = read_NovAtel(FID, EPOCH, tempEPH);
%    if FileEnd == 1, break; end
%end

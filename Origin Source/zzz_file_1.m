%% 시간에 따른 계산된 ENU값 조합
clc
clear all

k=2;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
temp1 = load(file);

data = [temp1(:,1), temp1(:,20:23), temp1(:,26:28), NaN(size(temp1, 1), 1)];

for k=3:32
    c = clock;disp([k, c(5), c(6)]);
    clear temp*
    
    % 읽음
    file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
    temp1 = load(file);
    if isempty(temp1), disp('No Data'); continue; end
    temp2 = [temp1(:,1), temp1(:,20:23), temp1(:,26:28), NaN(size(temp1, 1), 1)];
    
    data = [data; temp2];
    
    % 시간 정렬
    data = sortrows(data, 1);
    
    % 같은 시간 제거
    temp3 = size(data, 1);
    data(2:temp3, 9) = data(2:temp3, 1) - data(1:temp3-1, 1);
    data(1, 9) = 0.5;
    
    del_PRN = find(data(:,9) == 0);
    if(~isempty(del_PRN)), data(del_PRN, :) = []; end
end

%% 시간에 따른 위성 표기
clc
clear all

SV01_1 = [];SV02_1 = [];SV03_1 = [];SV04_1 = [];SV05_1 = [];SV06_1 = [];SV07_1 = [];SV08_1 = [];SV09_1 = [];SV10_1 = [];
SV11_1 = [];SV12_1 = [];SV13_1 = [];SV14_1 = [];SV15_1 = [];SV16_1 = [];SV17_1 = [];SV18_1 = [];SV19_1 = [];SV20_1 = [];
SV21_1 = [];SV22_1 = [];SV23_1 = [];SV24_1 = [];SV25_1 = [];SV26_1 = [];SV27_1 = [];SV28_1 = [];SV29_1 = [];SV30_1 = [];
SV31_1 = [];SV32_1 = [];temp1 = [];

k=2;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.mat'];
load(file);
if ~isempty(SV01_1), temp1 = SV01_1; end
if ~isempty(SV02_1), temp1 = SV02_1; end
if ~isempty(SV03_1), temp1 = SV03_1; end
if ~isempty(SV04_1), temp1 = SV04_1; end
if ~isempty(SV05_1), temp1 = SV05_1; end
if ~isempty(SV06_1), temp1 = SV06_1; end
if ~isempty(SV07_1), temp1 = SV07_1; end
if ~isempty(SV08_1), temp1 = SV08_1; end
if ~isempty(SV09_1), temp1 = SV09_1; end
if ~isempty(SV10_1), temp1 = SV10_1; end
if ~isempty(SV11_1), temp1 = SV11_1; end
if ~isempty(SV12_1), temp1 = SV12_1; end
if ~isempty(SV13_1), temp1 = SV13_1; end
if ~isempty(SV14_1), temp1 = SV14_1; end
if ~isempty(SV15_1), temp1 = SV15_1; end
if ~isempty(SV16_1), temp1 = SV16_1; end
if ~isempty(SV17_1), temp1 = SV17_1; end
if ~isempty(SV18_1), temp1 = SV18_1; end
if ~isempty(SV19_1), temp1 = SV19_1; end
if ~isempty(SV20_1), temp1 = SV20_1; end
if ~isempty(SV21_1), temp1 = SV21_1; end
if ~isempty(SV22_1), temp1 = SV22_1; end
if ~isempty(SV23_1), temp1 = SV23_1; end
if ~isempty(SV24_1), temp1 = SV24_1; end
if ~isempty(SV25_1), temp1 = SV25_1; end
if ~isempty(SV26_1), temp1 = SV26_1; end
if ~isempty(SV27_1), temp1 = SV27_1; end
if ~isempty(SV28_1), temp1 = SV28_1; end
if ~isempty(SV29_1), temp1 = SV29_1; end
if ~isempty(SV30_1), temp1 = SV30_1; end
if ~isempty(SV31_1), temp1 = SV31_1; end
if ~isempty(SV32_1), temp1 = SV32_1; end

% data: [PRN_OX 1~32, GPS time, NumOfSV, temp]
data = [NaN(size(temp1, 1), 32), temp1(:,1), ones(size(temp1, 1), 1), NaN(size(temp1, 1), 1)];
data(1, 35) = 0.5;
data(:, k) = k;

for k=3:32
    c = clock;disp([k, c(5), c(6)]);
    clear temp*
    SV01_1 = [];SV02_1 = [];SV03_1 = [];SV04_1 = [];SV05_1 = [];SV06_1 = [];SV07_1 = [];SV08_1 = [];SV09_1 = [];SV10_1 = [];
    SV11_1 = [];SV12_1 = [];SV13_1 = [];SV14_1 = [];SV15_1 = [];SV16_1 = [];SV17_1 = [];SV18_1 = [];SV19_1 = [];SV20_1 = [];
    SV21_1 = [];SV22_1 = [];SV23_1 = [];SV24_1 = [];SV25_1 = [];SV26_1 = [];SV27_1 = [];SV28_1 = [];SV29_1 = [];SV30_1 = [];
    SV31_1 = [];SV32_1 = [];temp1 = [];
    
    % 읽음
    file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.mat'];
    load(file);
    if ~isempty(SV01_1), temp1 = SV01_1; end
    if ~isempty(SV02_1), temp1 = SV02_1; end
    if ~isempty(SV03_1), temp1 = SV03_1; end
    if ~isempty(SV04_1), temp1 = SV04_1; end
    if ~isempty(SV05_1), temp1 = SV05_1; end
    if ~isempty(SV06_1), temp1 = SV06_1; end
    if ~isempty(SV07_1), temp1 = SV07_1; end
    if ~isempty(SV08_1), temp1 = SV08_1; end
    if ~isempty(SV09_1), temp1 = SV09_1; end
    if ~isempty(SV10_1), temp1 = SV10_1; end
    if ~isempty(SV11_1), temp1 = SV11_1; end
    if ~isempty(SV12_1), temp1 = SV12_1; end
    if ~isempty(SV13_1), temp1 = SV13_1; end
    if ~isempty(SV14_1), temp1 = SV14_1; end
    if ~isempty(SV15_1), temp1 = SV15_1; end
    if ~isempty(SV16_1), temp1 = SV16_1; end
    if ~isempty(SV17_1), temp1 = SV17_1; end
    if ~isempty(SV18_1), temp1 = SV18_1; end
    if ~isempty(SV19_1), temp1 = SV19_1; end
    if ~isempty(SV20_1), temp1 = SV20_1; end
    if ~isempty(SV21_1), temp1 = SV21_1; end
    if ~isempty(SV22_1), temp1 = SV22_1; end
    if ~isempty(SV23_1), temp1 = SV23_1; end
    if ~isempty(SV24_1), temp1 = SV24_1; end
    if ~isempty(SV25_1), temp1 = SV25_1; end
    if ~isempty(SV26_1), temp1 = SV26_1; end
    if ~isempty(SV27_1), temp1 = SV27_1; end
    if ~isempty(SV28_1), temp1 = SV28_1; end
    if ~isempty(SV29_1), temp1 = SV29_1; end
    if ~isempty(SV30_1), temp1 = SV30_1; end
    if ~isempty(SV31_1), temp1 = SV31_1; end
    if ~isempty(SV32_1), temp1 = SV32_1; end
    
    if isempty(temp1), disp('No Data'); continue; end
    temp2 = [NaN(size(temp1, 1), 32), temp1(:,1), ones(size(temp1, 1), 1), NaN(size(temp1, 1), 1)];
    temp2(:, k) = k;clear temp1
    
    data = [data; temp2];clear temp2
    
    % 시간 정렬
    data = sortrows(data, 33);
    
    % 같은 시간 제거
    temp3 = size(data, 1);
    data(2:temp3, 35) = data(2:temp3, 33) - data(1:temp3-1, 33);
    data(1, 35) = 0.5;
    
    del_PRN = find(data(:,35) == 0);
    if(~isempty(del_PRN))
        data(del_PRN-1, k) = k;
        data(del_PRN-1, 34) = data(del_PRN-1, 34) + 1;
        data(del_PRN, :) = [];
    end
end

%%
clear all
k=1;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV01_1 = load(file);clear c file  k;data = SV01_1;
save -v6 SV01_1 data
clear all
k=1;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV01_2 = load(file);clear c file  k;data = SV01_2;
save -v6 SV01_2 data

clear all
k=2;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV02_1 = load(file);clear c file  k;data = SV02_1;
save -v6 SV02_1 data

clear all
k=2;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV02_2 = load(file);clear c file  k;data = SV02_2;
save -v6 SV02_2 data

clear all
k=3;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV03_1 = load(file);clear c file  k;data = SV03_1;
save -v6 SV03_1 data
clear all
k=3;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV03_2 = load(file);clear c file  k;data = SV03_2;
save -v6 SV03_2 data

clear all
k=4;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV04_1 = load(file);clear c file  k;data = SV04_1;
save -v6 SV04_1 data
clear all
k=4;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV04_2 = load(file);clear c file  k;data = SV04_2;
save -v6 SV04_2 data

clear all
k=5;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV05_1 = load(file);clear c file  k;data = SV05_1;
save -v6 SV05_1 data
clear all
k=5;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV05_2 = load(file);clear c file  k;data = SV05_2;
save -v6 SV05_2 data

clear all
k=6;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV06_1 = load(file);clear c file  k;data = SV06_1;
save -v6 SV06_1 data
clear all
k=6;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV06_2 = load(file);clear c file  k;data = SV06_2;
save -v6 SV06_2 data

clear all
k=7;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV07_1 = load(file);clear c file  k;data = SV07_1;
save -v6 SV07_1 data
clear all
k=7;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV07_2 = load(file);clear c file  k;data = SV07_2;
save -v6 SV07_2 data

clear all
k=8;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV08_1 = load(file);clear c file  k;data = SV08_1;
save -v6 SV08_1 data
clear all
k=8;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV08_2 = load(file);clear c file  k;data = SV08_2;
save -v6 SV08_2 data

clear all
k=9;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV09_1 = load(file);clear c file  k;data = SV09_1;
save -v6 SV09_1 data
clear all
k=9;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV09_2 = load(file);clear c file  k;data = SV09_2;
save -v6 SV09_2 data

clear all
k=10;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV10_1 = load(file);clear c file  k;data = SV10_1;
save -v6 SV10_1 data
clear all
k=10;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV10_2 = load(file);clear c file  k;data = SV10_2;
save -v6 SV10_2 data

clear all
k=11;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV11_1 = load(file);clear c file  k;data = SV11_1;
save -v6 SV11_1 data
clear all
k=11;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV11_2 = load(file);clear c file  k;data = SV11_2;
save -v6 SV11_2 data

clear all
k=12;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV12_1 = load(file);clear c file  k;data = SV12_1;
save -v6 SV12_1 data
clear all
k=12;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV12_2 = load(file);clear c file  k;data = SV12_2;
save -v6 SV12_2 data

clear all
k=13;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV13_1 = load(file);clear c file  k;data = SV13_1;
save -v6 SV13_1 data
clear all
k=13;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV13_2 = load(file);clear c file  k;data = SV13_2;
save -v6 SV13_2 data

clear all
k=14;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV14_1 = load(file);clear c file  k;data = SV14_1;
save -v6 SV14_1 data
clear all
k=14;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV14_2 = load(file);clear c file  k;data = SV14_2;
save -v6 SV14_2 data

clear all
k=15;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV15_1 = load(file);clear c file  k;data = SV15_1;
save -v6 SV15_1 data
clear all
k=15;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV15_2 = load(file);clear c file  k;data = SV15_2;
save -v6 SV15_2 data

clear all
k=16;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV16_1 = load(file);clear c file  k;data = SV16_1;
save -v6 SV16_1 data
clear all
k=16;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV16_2 = load(file);clear c file  k;data = SV16_2;
save -v6 SV16_2 data

clear all
k=17;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV17_1 = load(file);clear c file  k;data = SV17_1;
save -v6 SV17_1 data
clear all
k=17;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV17_2 = load(file);clear c file  k;data = SV17_2;
save -v6 SV17_2 data

clear all
k=18;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV18_1 = load(file);clear c file  k;data = SV18_1;
save -v6 SV18_1 data
clear all
k=18;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV18_2 = load(file);clear c file  k;data = SV18_2;
save -v6 SV18_2 data

clear all
k=19;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV19_1 = load(file);clear c file  k;data = SV19_1;
save -v6 SV19_1 data
clear all
k=19;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV19_2 = load(file);clear c file  k;data = SV19_2;
save -v6 SV19_2 data

clear all
k=20;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV20_1 = load(file);clear c file  k;data = SV20_1;
save -v6 SV20_1 data
clear all
k=20;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV20_2 = load(file);clear c file  k;data = SV20_2;
save -v6 SV20_2 data

clear all
k=21;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV21_1 = load(file);clear c file  k;data = SV21_1;
save -v6 SV21_1 data
clear all
k=21;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV21_2 = load(file);clear c file  k;data = SV21_2;
save -v6 SV21_2 data

clear all
k=22;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV22_1 = load(file);clear c file  k;data = SV22_1;
save -v6 SV22_1 data
clear all
k=22;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV22_2 = load(file);clear c file  k;data = SV22_2;
save -v6 SV22_2 data

clear all
k=23;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV23_1 = load(file);clear c file  k;data = SV23_1;
save -v6 SV23_1 data
clear all
k=23;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV23_2 = load(file);clear c file  k;data = SV23_2;
save -v6 SV23_2 data

clear all
k=24;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV24_1 = load(file);clear c file  k;data = SV24_1;
save -v6 SV24_1 data
clear all
k=24;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV24_2 = load(file);clear c file  k;data = SV24_2;
save -v6 SV24_2 data

clear all
k=25;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV25_1 = load(file);clear c file  k;data = SV25_1;
save -v6 SV25_1 data
clear all
k=25;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV25_2 = load(file);clear c file  k;data = SV25_2;
save -v6 SV25_2 data

clear all
k=26;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV26_1 = load(file);clear c file  k;data = SV26_1;
save -v6 SV26_1 data
clear all
k=26;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV26_2 = load(file);clear c file  k;data = SV26_2;
save -v6 SV26_2 data

clear all
k=27;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV27_1 = load(file);clear c file  k;data = SV27_1;
save -v6 SV27_1 data
clear all
k=27;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV27_2 = load(file);clear c file  k;data = SV27_2;
save -v6 SV27_2 data

clear all
k=28;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV28_1 = load(file);clear c file  k;data = SV28_1;
save -v6 SV28_1 data
clear all
k=28;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV28_2 = load(file);clear c file  k;data = SV28_2;
save -v6 SV28_2 data

clear all
k=29;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV29_1 = load(file);clear c file  k;data = SV29_1;
save -v6 SV29_1 data
clear all
k=29;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV29_2 = load(file);clear c file  k;data = SV29_2;
save -v6 SV29_2 data

clear all
k=30;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV30_1 = load(file);clear c file  k;data = SV30_1;
save -v6 SV30_1 data
clear all
k=30;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV30_2 = load(file);clear c file  k;data = SV30_2;
save -v6 SV30_2 data

clear all
k=31;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV31_1 = load(file);clear c file  k;data = SV31_1;
save -v6 SV31_1 data
clear all
k=31;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV31_2 = load(file);clear c file  k;data = SV31_2;
save -v6 SV31_2 data

clear all
k=32;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_1.txt'];
SV32_1 = load(file);clear c file  k;data = SV32_1;
save -v6 SV32_1 data
clear all
k=32;c = clock;disp([k, c(5), c(6)]);
file = ['D:\12_RTK\DATA_FILES\SV_DATA_2008081215\SV', num2str(k, '%.2i'), '_2.txt'];
SV32_2 = load(file);clear c file  k;data = SV32_2;
save -v6 SV32_2 data

%%

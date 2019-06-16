clear all
close all
clc

i=1;
l=1;
N=1;
N1=1;
N2=1;
N3=1;
N4=1;
L1=1575.42*10^6;
L2=1227.60*10^6;

code_sat=0;
code_rng=0;
count=0;

addpath('새 폴더/');

FID=fopen('1.baseusb-good.gps');
DGPS_base=[-3073914.4265,4088898.3051,3796975.3448];
%[36.7691336844761,126.934777399911,124.814292907715]
%-3073914.3810,4088898.2585,3796975.3214
DGPS_pos=ecef2lla(DGPS_base);

while 1
    
    data{N,1}=fgetl(FID);
    datascan=strread(data{N}, '%s', 'delimiter', ',');
    
    switch datascan{1}
        
        case '#BESTPOSA'
            
            [data_BESTPOS{N1,1}, user_BESTPOS(N1,:), time_BESTPOS(N1,:)]=read_BESTPOS(data{N,1});
            N1=N1+1;
            
        case '#BESTXYZA'
            
            [data_BESTXYZ{N2,1}, xyz_BESTXYZ(N2,1:3), user_BESTXYZ(N2,1:3), time_BESTXYZ(N2,:)]=read_BESTXYZ(data{N,1});
            N2=N2+1;
            count=count+1;
            
        case '#SATXYZ2A'
            
            [data_SATXYZ2{N3,1}, sat_sat(N3,1), satpos{N3,1}, corr{N3,1}, time_SATXYZ2(N3,:), code_sat]=read_SATXYZ2(data{N,1});
            count=count+1;
            N3=N3+1;
            
        case '#RANGEA'
            
            [data_RANGE{N4,1}, sat_rng(N4,1), pseudo{N4,1}, carry{N4,1}, time_RANGE(N4,:), code_rng]=read_RANGE(data{N,1});
            count=count+1;
            N4=N4+1;
            
    end
    
    N=N+1;
    
    if and(code_sat, code_rng)==1 && count==3
        
        if i==1
            
            [estuser(i,1:4), prc{i,1}] = LS_pos(20, satpos{i}, pseudo{i}, corr{i});
            estpos(i,1:3)=ecef2lla(estuser(i,1:3));
            [prc{i,1}, geoP{i,1}]=calPRC(estuser(i,1:3), satpos{i}, pseudo{i}, corr{i});
            
            fprintf('1번째 위치 (Base) [%d-%02d-%02d %02d:%02d:%02d] : %.10f %.10f %.2fm\n', time_SATXYZ2(1,1), time_SATXYZ2(1,2), time_SATXYZ2(1,3), time_SATXYZ2(1,4), time_SATXYZ2(1,5), time_SATXYZ2(1,6), estpos(1,1), estpos(1,2), estpos(1,3));
            
            i=i+1;
            code_sat=0;
            code_rng=0;
            count=0;
            
        elseif i > 1
            
            estuser(i,1:4) = LS_pos(20, satpos{i}, pseudo{i}, corr{i}, estuser(i-1,1:4));
            estpos(i,1:3)=ecef2lla(estuser(i,1:3));
            [prc{i,1}, geoP{i,1}]=calPRC(estuser(i,1:3), satpos{i}, pseudo{i}, corr{i});
            
            fprintf('%d번째 위치 (Base) [%d-%02d-%02d %02d:%02d:%02d] : %.10f %.10f %.2fm\n', i, time_SATXYZ2(i,1), time_SATXYZ2(i,2), time_SATXYZ2(i,3), time_SATXYZ2(i,4), time_SATXYZ2(i,5), time_SATXYZ2(i,6), estpos(i,1), estpos(i,2), estpos(i,3));
            
            i=i+1;
            code_sat=0;
            code_rng=0;
            count=0;
            
        end
        
    end
    
    if feof(FID)
        
        break;
        
    end
    
end

save('base', 'sat_sat', 'satpos', 'pseudo', 'corr', 'geoP', 'prc');
fprintf('출력 완료\n')

for l=1:N3-1
    
    e_x(l,1)=xyz_BESTXYZ(l,1)-estuser(l,1);
    e_y(l,1)=xyz_BESTXYZ(l,2)-estuser(l,2);
    e_z(l,1)=xyz_BESTXYZ(l,3)-estuser(l,3);
    
end

rms(1,1)=sqrt(sum(e_x.^2)/(l-1));
rms(1,2)=sqrt(sum(e_y.^2)/(l-1));
rms(1,3)=sqrt(sum(e_z.^2)/(l-1));

fprintf('Single GPS Position RMS   X : %f   Y : %f   Z : %f\n', rms(1,1), rms(1,2), rms(1,3))

figure()
plot(e_x, e_y, 'o', 'markersize', 0.5)
xlim([-20,20]);
grid on
ylim([-20,20]);
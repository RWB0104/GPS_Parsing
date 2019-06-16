clear all
close all
clc

i=1;
N=1;
N1=1;
N2=1;
N3=1;
N4=1;

code_sat=0;
code_rng=0;
count=0;

FID=fopen('`18.05.11 (금) 외부 nR 16-12 16-42.gps');

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
            
        case '#SATXYZ2A'
            
            [data_SATXYZ2{N3,1}, sat_sat(N3,1), satpos{N3,1}, corr{N3,1}, time_SATXYZ2(N3,:), code_sat]=read_SATXYZ2(data{N,1});
            count=count+1;
            N3=N3+1;
            
        case '#RANGEA'
            
            [data_RANGE{N4,1}, sat_rng(N4,1), pseudo{N4,1}, time_RANGE(N4,:), code_rng]=read_RANGE(data{N,1});
            count=count+1;
            N4=N4+1;
            
    end
    
    N=N+1;
    count_i(i,1)=i;
    
    if and(code_sat, code_rng)==1 && count==2
        
        if i==1
            
            estuser(i,1:4) = LS_pos(20, satpos{i}, pseudo{i}, corr{i});
            estpos(i,1:3)=ecef2lla(estuser(i,1:3));
            
            %fprintf('1번째 위치 (Single) [%d-%02d-%02d %02d:%02d:%02d] : %.10f %.10f %.2fm\n', time_SATXYZ2(1,1), time_SATXYZ2(1,2), time_SATXYZ2(1,3), time_SATXYZ2(1,4), time_SATXYZ2(1,5), time_SATXYZ2(1,6), estpos(1,1), estpos(1,2), estpos(1,3));
            
            i=i+1;
            code_sat=0;
            code_rng=0;
            count=0;
            
        elseif i > 1
            
            estuser(i,1:4) = LS_pos(20, satpos{i}, pseudo{i}, corr{i}, estuser(i-1,1:4));
            estpos(i,1:3)=ecef2lla(estuser(i,1:3));
            
            %fprintf('%d번째 위치 (Single) [%d-%02d-%02d %02d:%02d:%02d] : %.10f %.10f %.2fm\n', i, time_SATXYZ2(i,1), time_SATXYZ2(i,2), time_SATXYZ2(i,3), time_SATXYZ2(i,4), time_SATXYZ2(i,5), time_SATXYZ2(i,6), estpos(i,1), estpos(i,2), estpos(i,3));
            
            i=i+1;
            code_sat=0;
            code_rng=0;
            count=0;
            
        end
        
    elseif and(code_sat, code_rng)==0 && count==2
        
        estuser(i,1:4)=estuser(i-1,1:4);
        estpos(i,1:3)=ecef2lla(estuser(i-1,1:3));
        count=0;
        i=i+1;
        
    end
    
    
    
    if feof(FID)
        
        break;
        
    end
    
end
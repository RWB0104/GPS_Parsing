clear all
close all
clc

FID=fopen('test1_2008070910.gps');
%FID=fopen('KARI_2008082731.gps');
%FID=fopen('160909.gps');
save_llhsat=fopen('llh_SAT.txt','w');
psedo_L=fopen('Pseudorange.txt','w');

nmea=cell(99,1);
head=cell(99,1);
real=cell(99,1);

nmea_best=cell(99,1);
nmea_sat=cell(3,1);

llh_best=zeros(3,4);
llh_sat=zeros(4,4);

long=15000;
i=1;
j=0;
k=0;
h=0;
L=0;
m=0;
n=0;

c=300000000;
ps=1;
pl=1;

for i=1:long
    nmea{i}=fgetl(FID);
    [head{i},real{i}]=strtok(nmea{i},';');
    scan = strread(nmea{i}, '%s', 'delimiter', ',');  
    scan1=strread(real{i}, '%s', 'delimiter', ',');
    scan_head{i}=strread(head{i}, '%s', 'delimiter', ',');
    
    switch scan{1}
        case '#BESTXYZA' %BESTXYZ 저장
            nmea_best{j+1}=nmea{i};
            j=j+1;
                    
            time(1,1)=str2double(scan{6})*604800+str2double(scan{7});
            time(1,2)=str2double(scan{7});

            xyz1(j,1)=str2double(scan1{3});
            xyz1(j,2)=str2double(scan1{4});
            xyz1(j,3)=str2double(scan1{5});
            
            [lat, lon, alt]= ecef2lla(xyz1(1,1),xyz1(1,2),xyz1(1,3));
            llh_best(1,j)=lat;
            llh_best(2,j)=lon;
            llh_best(3,j)=alt;

        case '#SATXYZA' %SATXTZ 저장
            nmea_sat{k+1}=nmea{i};
            k=k+1;
            
            satlong=str2double(scan1{2}); % 위성 갯수 추출
            
            for h=0:satlong-1 %위성의 갯수에 따라 xyz계산
                
                str2double(scan1{3+h*9});
                
                if str2double(scan1{3+h*9})<=30
                
                    time(1,1)=str2double(scan{6})*604800+str2double(scan{7});
                    time(1,2)=mod(str2double(scan{6}),1024);
                    time(1,3)=str2double(scan{7});
                    
                    %UTC_TIME(h+1,:) = gps2utc([mod(str2double(scan{6}), 1024) str2double(scan{7})]);
                    
                    xyz(h+1,1+((k-1)*3))=str2double(scan1{4+h*9});
                    xyz(h+1,2+((k-1)*3))=str2double(scan1{5+h*9});
                    xyz(h+1,3+((k-1)*3))=str2double(scan1{6+h*9});
                    %xyz(h+1,4+((k-1)*6))=str2double(scan1{7+h*9});
                    %xyz(h+1,5+((k-1)*6))=str2double(scan1{8+h*9});
                    %xyz(h+1,6+((k-1)*6))=str2double(scan1{9+h*9});
                    
                end
            end
            
            fprintf(save_llhsat,'PRN : %d\t 위도 : %f\t 경도 : %f\t 높이 : %f\t\n\n', llh_sat(:));
            
            if h==satlong-1
                
                fprintf(save_llhsat,'\n');
                
            end
            
        case '#RANGEA'
            nmea_range{m+1,1}=nmea{i};
            m=m+1;
            satlong1=str2double(strrep(scan1{1},';',''));
            
            for n=0:(satlong1/2)-1
                
                range_data((m*3)-2,n+1)=str2double(scan1{2+n*20});
                range_data((m*3)-1,n+1)=str2double(scan1{4+n*20});
                range_data((m*3),n+1)=str2double(scan1{5+n*20});

            end

             fprintf(psedo_L,'PRN : %d\t   의사거리 : %0.2fkm\t\n\n',  range_data(1:2));
            
            if n==(satlong1/2)-1
                
                fprintf(psedo_L,'\n');
                
            end
    end
end
fclose(save_llhsat);
fclose(FID);

%save=fopen('NMEA.txt','w');
%fprintf(save,'%s\n\n',nmea{:,1});
%fclose(save);

%save_best=fopen('NMEA_BEST.txt','w');
%fprintf(save_best,'%s\n\n', nmea_best{:,1});
%fclose(save_best);

%save_sat=fopen('NMEA_SAT.txt','w');
%fprintf(save_sat,'%s\n\n',nmea_sat{:,1});
%fclose(save_sat);

%save_llhbest=fopen('llh_BEST.txt','w');
%fprintf(save_llhbest,'위도 : %f\t   경도 : %f\t   높이 : %f\t\n\n', llh_best(:));
%fclose(save_llhbest);

estuser = [0; 0; 0; 0]; %delta x y z t
p=zeros(satlong,1);
P(1:6,1)=range_data(2,1:6);
L=zeros(satlong,1);
estuser1=zeros(4,10);
a=ones(satlong,4);

for pl=1:20
    
    for ps=1:satlong
        
        estuser1(:,pl)=estuser;
        p(ps,1) = norm(xyz(ps,1:3)-estuser(1:3)');
        p1(ps,pl)=p(ps,1);
       
        %L(ps,1)=P(ps,1)-p(ps,1)+xyz(ps,4)-xyz(ps,5)-xyz(ps,6);
        L(ps,1)=P(ps,1)-p(ps,1)-estuser(4,1);
        L1(ps,pl)=L(ps,1);
        
        a(ps,1)=estuser(1,1)-xyz(ps,1);
        a(ps,2)=estuser(2,1)-xyz(ps,2);
        a(ps,3)=estuser(3,1)-xyz(ps,3);
        a(ps,4)=1;
    
    end

A=[a(1,1)/p(1,1) a(1,2)/p(1,1) a(1,3)/p(1,1) a(1,4);
    a(2,1)/p(2,1) a(2,2)/p(2,1) a(2,3)/p(2,1) a(2,4);
    a(3,1)/p(3,1) a(3,2)/p(3,1) a(3,3)/p(3,1) a(3,4);
    a(4,1)/p(4,1) a(4,2)/p(4,1) a(4,3)/p(4,1) a(4,4);
    a(5,1)/p(5,1) a(5,2)/p(5,1) a(5,3)/p(5,1) a(5,4);
    a(6,1)/p(6,1) a(6,2)/p(6,1) a(6,3)/p(6,1) a(6,4);
    a(7,1)/p(7,1) a(7,2)/p(7,1) a(7,3)/p(7,1) a(7,4);
   a(8,1)/p(8,1) a(8,2)/p(8,1) a(8,3)/p(8,1) a(8,4)];

    X=A\L;
    x(:,pl)=X;
    estuser(1,1)=estuser(1,1)+X(1,1);
    estuser(2,1)=estuser(2,1)+X(2,1);
    estuser(3,1)=estuser(3,1)+X(3,1);
    estuser(4,1)=estuser(4,1)+X(4,1);
    estuser1(:,pl)=estuser;
    
    
end

[estlat estlon estalt]= ecef2lla(estuser(1,1),estuser(2,1),estuser(3,1));

estlat
estlon
estalt
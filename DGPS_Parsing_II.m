clear all
close all
clc

B=load('base.mat');
R=load('rover.mat');

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


while 1
    
    %estuser(i,1:4) = DLS_pos2(50, satpos, p, corr, PRC, recent)
    estuser(i,1:4) = DLS_pos3(20, R.satpos{i}, R.pseudo{i}, R.geoP{i}, R.corr{i}, B.pseudo{i}, B.geoP{i}, B.corr{i}, B.prc{i}, R.estuser(i,1:4));
    estpos(i,1:3)=ecef2lla(estuser(i,1:3));
    
    fprintf('%d번째 위치 (DGPS) : %.10f %.10f %.2fm\n', i, estpos(i,1), estpos(i,2), estpos(i,3));
    
    i=i+1;
    
    if i==1801
        
        break;
        
    end
    
end

%makekml(estpos);

for l=1:i-1
    
    e_x(l,1)=R.xyz_BESTXYZ(l,1)-estuser(l,1);
    e_y(l,1)=R.xyz_BESTXYZ(l,2)-estuser(l,2);
    e_z(l,1)=R.xyz_BESTXYZ(l,3)-estuser(l,3);
    
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
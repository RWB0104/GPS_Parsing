clear all
close all
clc
addpath('googleearth/');

i=1;
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

DGPS=1;
B=0;

if B==0
    
    rpos=[36.7681912393395,126.927312385572,115.488252007402];
    rbase=[-3073414.83887441,4089342.87514722,3796886.05963248];
    FID=fopen('1.rover-bad.gps');
    
    if DGPS==1
        
        D=load('base.mat');
        %D=load('rover.mat');
        
    end
    
elseif B==1
    
    rpos=[36.76913371684,126.93477741224,124.720842435956];
    rbase=[-3073914.4265,4088898.3051,3796975.3448];
    FID=fopen('1.baseusb-good.gps');
end

while 1
    
    data{N,1}=fgetl(FID);
    datascan=strread(data{N}, '%s', 'delimiter', ',');
    
    switch datascan{1}
        
        case '#BESTPOSA'
            
            [data_BESTPOS{N1,1}, user_BESTPOS(N1,:), time_BESTPOS(N1,:)]=read_BESTPOS(data{N,1});
            xyz_BESTPOS(N1,:)=lla2ecef(user_BESTPOS(N1,:));
            N1=N1+1;
            
        case '#BESTXYZA'
            
            [data_BESTXYZ{N2,1}, xyz_BESTXYZ(N2,1:3), user_BESTXYZ(N2,1:3), time_BESTXYZ(N2,:)]=read_BESTXYZ(data{N,1});
            N2=N2+1;
            
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
    
    if DGPS==0
        
        if and(code_sat, code_rng)==1 && count==2
            
            if i==1
                
                [estuser(i,1:4), dop(i,1)] = LS_pos(20, satpos{i}, pseudo{i}, corr{i});
                estpos(i,1:3)=ecef2lla(estuser(i,1:3));
                [de(i,1), dn(i,1)]=ecef2enu(estuser(i,1), estuser(i,2), estuser(i,3), rpos(1,1), rpos(1,2), rpos(1,3), wgs84Ellipsoid);
                
                fprintf('1번째 위치 (Single) [%d-%02d-%02d %02d:%02d:%02d] : %.10f %.10f %.2fm GDOP %.2f\n', time_SATXYZ2(1,1), time_SATXYZ2(1,2), time_SATXYZ2(1,3), time_SATXYZ2(1,4), time_SATXYZ2(1,5), time_SATXYZ2(1,6), estpos(1,1), estpos(1,2), estpos(1,3), dop(1,1));
                
                i=i+1;
                code_sat=0;
                code_rng=0;
                count=0;
                
            elseif i > 1
                
                [estuser(i,1:4), dop(i,1)] = LS_pos(20, satpos{i}, pseudo{i}, corr{i}, estuser(i-1,1:4));
                estpos(i,1:3)=ecef2lla(estuser(i,1:3));
                [de(i,1), dn(i,1)]=ecef2enu(estuser(i,1), estuser(i,2), estuser(i,3), rpos(1,1), rpos(1,2), rpos(1,3), wgs84Ellipsoid);
                
                fprintf('%d번째 위치 (Single) [%d-%02d-%02d %02d:%02d:%02d] : %.10f %.10f %.2fm GDOP %.2f\n', i, time_SATXYZ2(i,1), time_SATXYZ2(i,2), time_SATXYZ2(i,3), time_SATXYZ2(i,4), time_SATXYZ2(i,5), time_SATXYZ2(i,6), estpos(i,1), estpos(i,2), estpos(i,3), dop(i,1));
                
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
        
    end
    
    %%%%%%%%%%%%%%%   DGPS   %%%%%%%%%%%%%%%%%%%
    
    if DGPS==1
        
        if and(code_sat, code_rng)==1 && count==2
            
            if i==1
                
                [Destuser(i,1:4), Ddop(i,1), Dsat_sat(i,1)] = DLS_pos2(20, satpos{i}, pseudo{i}, D.corr{i}, D.prc{i}, corr{i});
                %Destuser(i,1:4) = DLS_pos3(20, satpos{i}, pseudo{i}, corr{i}, D.geoP{i}, D.pseudo{i}, D.corr{i}, D.prc{i});
                %Destuser(i,1:4) = DLS_pos(20, satpos{i}, pseudo{i}, corr{i}, D.pseudo{i,1}, D.geoP{i,1}, D.corr{i,1}, D.prc{i,1});
                Destpos(i,1:3)=ecef2lla(Destuser(i,1:3));
                [de(i,1), dn(i,1)]=ecef2enu(Destuser(i,1), Destuser(i,2), Destuser(i,3), rpos(1,1), rpos(1,2), rpos(1,3), wgs84Ellipsoid);
                
                fprintf('1번째 위치 (DGPS) [%d-%02d-%02d %02d:%02d:%02d] : %.10f %.10f %.2fm GDOP %.2f\n', time_SATXYZ2(1,1), time_SATXYZ2(1,2), time_SATXYZ2(1,3), time_SATXYZ2(1,4), time_SATXYZ2(1,5), time_SATXYZ2(1,6), Destpos(1,1), Destpos(1,2), Destpos(1,3), Ddop(1,1));
                
                i=i+1;
                code_sat=0;
                code_rng=0;
                count=0;
                
            elseif i > 1
                
                [Destuser(i,1:4), Ddop(i,1), Dsat_sat(i,1)] = DLS_pos2(20, satpos{i}, pseudo{i}, D.corr{i}, D.prc{i}, corr{i});
                %Destuser(i,1:4) = DLS_pos(20, satpos{i}, pseudo{i}, corr{i}, D.pseudo{i,1}, D.geoP{i,1}, D.corr{i,1}, D.prc{i,1}, Destuser(i-1,1:4));
                %Destuser(i,1:4) = DLS_pos3(20, satpos{i}, pseudo{i}, corr{i}, D.geoP{i}, D.pseudo{i}, D.corr{i}, D.prc{i}, Destuser(i-1,1:4));
                Destpos(i,1:3)=ecef2lla(Destuser(i,1:3));
                [de(i,1), dn(i,1)]=ecef2enu(Destuser(i,1), Destuser(i,2), Destuser(i,3), rpos(1,1), rpos(1,2), rpos(1,3), wgs84Ellipsoid);
                
                fprintf('%d번째 위치 (DGPS) [%d-%02d-%02d %02d:%02d:%02d] : %.10f %.10f %.2fm GDOP %.2f\n', i, time_SATXYZ2(i,1), time_SATXYZ2(i,2), time_SATXYZ2(i,3), time_SATXYZ2(i,4), time_SATXYZ2(i,5), time_SATXYZ2(i,6), Destpos(i,1), Destpos(i,2), Destpos(i,3), Ddop(i,1));
                
                i=i+1;
                code_sat=0;
                code_rng=0;
                count=0;
                
            end
            
        elseif and(code_sat, code_rng)==0 && count==2
            
            Destuser(i,1:4)=Destuser(i-1,1:4);
            Destpos(i,1:3)=ecef2lla(Destuser(i-1,1:3));
            count=0;
            i=i+1;
            
        end
        
    end
    
    if feof(FID)
        
        break;
        
    end
    
end

if DGPS==0
    
    for i=1:N3-1
        
        e_x(i,1)=rbase(1,1)-estuser(i,1);
        e_y(i,1)=rbase(1,2)-estuser(i,2);
        e_z(i,1)=rpos(1,3)-estpos(i,3);
        
    end
    
    rms(1,1)=sqrt(sum(e_x.^2)/(N3-1));
    rms(1,2)=sqrt(sum(e_y.^2)/(N3-1));
    rms(1,3)=sqrt(sum(e_z.^2)/(N3-1));
    
    rms2D=sqrt((sum(e_x.^2)+sum(e_y.^2))/(N3-1));
    rms3D=sqrt((sum(e_x.^2)+sum(e_y.^2)+sum(e_z.^2))/(N3-1));
    
    fprintf('Single GPS Position RMS   X : %f   Y : %f   Z : %f\n', rms(1,1), rms(1,2), rms(1,3))
    fprintf('Single GPS Position 2DRMS   %f\n', rms2D)
    fprintf('Single GPS Position 3DRMS   %f\n', rms3D)
    
    figure()
    plot(e_x, e_y, 'o', 'markersize', 0.5)
    title('X&Y standard deviation (Single GPS)')
    xlim([-20,20]);
    xlabel('\sigmax [m]')
    grid on
    ylim([-20,20]);
    ylabel('\sigmay [m]')
    
    t=(1:1:N3-1);
    
    figure()
    plot(t, sat_sat)
    title('Satellite number of epoch (Single GPS)')
    xlabel('time [s]')
    xlim([0,N3-1]);
    ylabel('Num')
    ylim([0,15]);
    
    figure()
    plot(t, dop)
    title('GDOP of epoch (Single GPS)')
    xlabel('time [s]')
    xlim([0,N3-1]);
    ylabel('GDOP')
    
    %     figure()
    %     plot(de, dn, 'o', 'markersize', 0.5)
    %     xlim([-20,20]);
    %     grid on
    %     ylim([-20,20]);
    %
    %     t=(1:1:N3-1);
    %
    %     figure()
    %     ax1=subplot(3,1,1);
    %     plot(t, estuser(:,1), t, xyz_BESTXYZ(:,1))
    %     title('Graph of  est X - measure X (Single GPS)')
    %     legend('est X','measure X')
    %     xlabel('Time [sec]')
    %     ylabel('X [m]')
    %     grid on
    %     grid minor
    %     xlim([0 N3-1]);
    %
    %     ax2=subplot(3,1,2);
    %     plot(t, estuser(:,2), t, xyz_BESTXYZ(:,2))
    %     title('Graph of  est Y - measure Y (Single GPS)')
    %     legend('est Y','measure Y')
    %     xlabel('Time [sec]')
    %     ylabel('Y [m]')
    %     grid on
    %     grid minor
    %     xlim([0 N3-1]);
    %
    %     ax3=subplot(3,1,3);
    %     plot(t, estuser(:,3), t, xyz_BESTXYZ(:,3))
    %     title('Graph of  est Z - measure Z (Single GPS)')
    %     legend('est Z','measure Z')
    %     ylabel('Z [m]')
    %     xlabel('Time [sec]')
    %     grid on
    %     grid minor
    %     xlim([0 N3-1]);
    
    makekml(estpos);
    
elseif DGPS==1
    
    for i=1:N1-1
        
        e_Dx(i,1)=rbase(1,1)-Destuser(i,1);
        e_Dy(i,1)=rbase(1,2)-Destuser(i,2);
        e_Dz(i,1)=rpos(1,3)-Destpos(i,3);
        
    end
    
    Drms(1,1)=sqrt(sum(e_Dx.^2)/(N1-1));
    Drms(1,2)=sqrt(sum(e_Dy.^2)/(N1-1));
    Drms(1,3)=sqrt(sum(e_Dz.^2)/(N1-1));
    
    Drms2D=sqrt((sum(e_Dx.^2)+sum(e_Dy.^2))/(N1-1));
    Drms3D=sqrt((sum(e_Dx.^2)+sum(e_Dy.^2)+sum(e_Dz.^2))/(N1-1));
    
    fprintf('DGPS Position RMS   X : %f   Y : %f   Z : %f\n', Drms(1,1), Drms(1,2), Drms(1,3))
    fprintf('DGPS Position 2DRMS   %f\n', Drms2D)
    fprintf('DGPS Position 3DRMS   %f\n', Drms3D)
    
    
    figure()
    plot(e_Dx, e_Dy, 'o', 'markersize', 0.5)
    title('X&Y standard deviation (DGPS)')
    xlim([-20,20]);
    xlabel('\sigmax [m]')
    grid on
    ylim([-20,20]);
    ylabel('\sigmay [m]')
    
    t=(1:1:N3-1);
    
    figure()
    plot(t, Dsat_sat)
    title('Satellite number of epoch (DGPS)')
    xlabel('time [s]')
    xlim([0,N3-1]);
    ylabel('Num')
    ylim([0,15]);
    
    figure()
    plot(t, Ddop)
    title('GDOP of epoch (DGPS)')
    xlabel('time [s]')
    xlim([0,N3-1]);
    ylabel('GDOP')
    
    %     figure()
    %     plot(de, dn, 'o', 'markersize', 0.5)
    %     xlim([-20,20]);
    %     grid on
    %     ylim([-20,20]);
    %
    %     t=(1:1:N3-1);
    %
    %     figure()
    %     ax1=subplot(3,1,1);
    %     plot(t, Destuser(:,1), t, xyz_BESTXYZ(:,1))
    %     title('Graph of  est X - measure X (DGPS)')
    %     legend('est X','measure X')
    %     xlabel('Time [sec]')
    %     ylabel('X [m]')
    %     grid on
    %     grid minor
    %     xlim([0 N3-1]);
    %
    %     ax2=subplot(3,1,2);
    %     plot(t, Destuser(:,2), t, xyz_BESTXYZ(:,2))
    %     title('Graph of  est Y - measure Y (DGPS)')
    %     legend('est Y','measure Y')
    %     xlabel('Time [sec]')
    %     ylabel('Y [m]')
    %     grid on
    %     grid minor
    %     xlim([0 N3-1]);
    %
    %     ax3=subplot(3,1,3);
    %     plot(t, Destuser(:,3), t, xyz_BESTXYZ(:,3))
    %     title('Graph of  est Z - measure Z (DGPS)')
    %     legend('est Z','measure Z')
    %     ylabel('Z [m]')
    %     xlabel('Time [sec]')
    %     grid on
    %     grid minor
    %     xlim([0 N3-1]);
    
    makekml(Destpos);
    
end

fprintf('\n제작 완료\n')
function [SV_xyz, del_t_SV]=SVPos(EPH, tc, del_t_tr, RCV_CLOCK_OFFS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SV xyz (ecef)                                  %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4, RCV_CLOCK_OFFS = 0; end
if nargin < 3, error('Wrong number of input arguments'); end

% IS-GPS-200D
mu = 3.986005e14;                                   % WGS 84 value of the earth's gravitational constant for GPS user
OMEGA_DOTe = 7.2921151467e-5;                       % WGS 84 value of the earth's rotation rate

A = EPH.sqrt_A^2;                                   % Semi-major axis
n0 = sqrt(mu/(A^3));                                % Computed mean motion (rad/sec)

tk = tc - EPH.TOE;                                  % Time from ephemeris reference epoch
% tmp = tk;
while tk > 302400, tk = tk - 604800; end
while tk < -302400, tk = tk + 604800; end
% if tk~=tmp, disp(tmp); end
n = n0 + EPH.Delta_n;                               % Corrected mean motion

Mk = EPH.M0 + (n*tk);

Ek = Mk;preEk = Ek-1;
while abs(Ek-preEk) > 1e-14
    preEk = Ek;
    Ek = Ek - (Ek-EPH.e*sin(Ek)-Mk) / (1-EPH.e*cos(Ek));
end

% FUNDAMENTALS OF GLOBAL POSITIONING SYSTEM RECEIVERS A SOFTWARE APPROACH (SECOND EDITION)
F = -4.442807633e-10;                               % 
del_tr = F * EPH.e * EPH.sqrt_A * sin(Ek) + RCV_CLOCK_OFFS;         % The relativistic correction term
del_t = EPH.af0 + EPH.af1*tk + EPH.af2*tk^2 + del_tr - EPH.TGD;     % The overall time correction term
del_t_SV = EPH.af0 + EPH.af1*tk + EPH.af2*tk^2 + del_tr;            % 반환값

t = tc - del_t;                                     % The GPS time of transmisstion

vk = atan2(sqrt(1-EPH.e^2)*sin(Ek),cos(Ek)-EPH.e);  % True Anomaly

Ek = acos((EPH.e+cos(vk))/(1+EPH.e*cos(vk)));       % Eccentric Anomaly

Pk = vk + EPH.omega;                                % Argument of Latitude

                                                    % Second Harmonic Pertubations
del_uk = EPH.Cus*sin(2*Pk) + EPH.Cuc*cos(2*Pk);     % Argument of Latitude Correction
del_rk = EPH.Crs*sin(2*Pk) + EPH.Crc*cos(2*Pk);     % Radius Correction
del_ik = EPH.Cis*sin(2*Pk) + EPH.Cic*cos(2*Pk);     % Inclination Correction

uk = Pk + del_uk;                                   % Corrected Argument of Latitude

rk = A * (1-EPH.e*cos(Ek)) + del_rk;                % Corrected Radius

ik = EPH.i0 + del_ik + EPH.IDOT * (t-EPH.TOE);      % Corrected Inclination

xpk = rk * cos(uk);                                 % Positions in orbital plane
ypk = rk * sin(uk);

OMEGAk = EPH.OMEGA0 + EPH.OMEGA_DOT * (t-EPH.TOE) - OMEGA_DOTe * t; % Corrected longitude of ascending node

% dOMEGAk = (EPH.OMEGA_DOT - OMEGA_DOTe) * del_t_tr; % 지구자전 보정
dOMEGAk = (EPH.OMEGA_DOT - OMEGA_DOTe) * (del_t_tr + del_t);        % 지구자전 보정 <- Novatel 수신기 값에 근접
OMEGAk = OMEGAk + dOMEGAk;

% xk = xpk*cos(OMEGAk)*cos(Pk) - ypk*cos(ik)*sin(OMEGAk)*sin(Pk);     % Earth-fixed coordinates
% yk = xpk*sin(OMEGAk)*cos(Pk) + ypk*cos(ik)*cos(OMEGAk)*sin(Pk);
% zk = ypk*sin(ik)*sin(Pk);

xk = xpk*cos(OMEGAk) - ypk*cos(ik)*sin(OMEGAk);     % Earth-fixed coordinates
yk = xpk*sin(OMEGAk) + ypk*cos(ik)*cos(OMEGAk);
zk = ypk*sin(ik);

%alpa = OMEGA_DOTe*del_t_tr;
%xk = xk*cos(alpa) + yk*sin(alpa);
%yk = -xk*sin(alpa) + yk*cos(alpa);

SV_xyz(1) = xk;
SV_xyz(2) = yk;
SV_xyz(3) = zk;

% EPH = struct('PRN', [], 'TOCYEAR', [], 'TOCMONTH', [], 'TOCDAY', [], 'TOCHOUR', [], 'TOCMINUTE', [], 'TOCSECOND', [], ...
%              'TOC', [], 'af0', [], 'af1', [], 'af2', [], 'IODE', [], 'Crs', [], 'Delta_n', [], 'M0', [], 'Cuc', [], ...
%              'e', [], 'Cus', [], 'sqrt_A', [], 'TOE', [], 'Cic', [], 'OMEGA0', [], 'Cis', [], 'i0', [], 'Crc', [], ...
%              'omega', [], 'OMEGA_DOT', [], 'IDOT', [], 'CodesOnL2Channel', [], 'GPSWeek', [], 'L2PDataFlag', [], ...
%              'SVAccuracy', [], 'SVHealth', [], 'TGD', [], 'IODC', [], 'GPSSecT', [], 'GPSWeekT', [], 'FitInterval', []);

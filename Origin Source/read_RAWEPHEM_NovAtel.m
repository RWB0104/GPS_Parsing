function EPH = read_RAWEPHEM_NovAtel(packet_data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read NovAtel ephemeris data                    %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

packet_data = strrep(packet_data, ',', ' ');
packet_data = strrep(packet_data, ';', ' ');
packet_data = strrep(packet_data, '*', ' ');

remain = strread(packet_data, '%s');

EPH = struct('PRN', [], 'TOCYear', [], 'TOCMonth', [], 'TOCDay', [], 'TOCHour', [], 'TOCMinute', [], 'TOCSecond', [], ...
             'TOC', [], 'af0', [], 'af1', [], 'af2', [], 'IODE', [], 'Crs', [], 'Delta_n', [], 'M0', [], 'Cuc', [], ...
             'e', [], 'Cus', [], 'sqrt_A', [], 'TOE', [], 'Cic', [], 'OMEGA0', [], 'Cis', [], 'i0', [], 'Crc', [], ...
             'omega', [], 'OMEGA_DOT', [], 'IDOT', [], 'CodesOnL2Channel', [], 'GPSWeek', [], 'L2PDataFlag', [], ...
             'SVAccuracy', [], 'SVHealth', [], 'TGD', [], 'IODC', [], 'GPSSecT', [], 'GPSWeekT', [], 'FitInterval', []);

EPH.GPSWeekT = str2double(remain{6});   % Transmission time of message (GPS Week, Continuous number(not mod(1024)!))
EPH.GPSSecT = str2double(remain{7});    % Transmission time of message (GPS Seconds)
EPH.PRN = str2double(remain{11});

% temp_week = str2double(remain{12});     % Ephemeris reference week number : NovAtel Receiver Data
% temp_sec = str2double(remain{13});      % Ephemeris reference time (s)    : NovAtel Receiver Data

%%%%%%%%%% Subframe 1 %%%%%%%%%%
% 8b073c --> TLM(22bits)+C(2bits)                               01~06(WORD 01)
% 8c9e26 --> HOW(22bits)+t(2bits)                               07~12(WORD 02)
% 73d0   --> WN(10bits)+C/A_OR_P_ON_L2(2bits)+URA_INDEX(4bits)  13~16(WORD 03)
% 00     --> SV_HEALTH(6bits)+IODC(2bits, MSBs)                 17~18(WORD 03)
% 7f1a6c --> L2_P_DATA_FLAG(1bit)+RESERVED(23bits)              19~24(WORD 04)
% 9d6d8e --> RESERVED(24bits)                                   25~30(WORD 05)
% 7850c7 --> RESERVED(24bits)                                   31~36(WORD 06)
% 8b33eb --> RESERVED(24bits)+TGD(8bits)                        37~42(WORD 07)
% 026977 --> IODC(8bit, LSBs)+TOC(16bit)                        43~48(WORD 08)
% 00ffc9 --> af2(8bit)+af1(16bit)                               49~54(WORD 09)
% ed8ee3 --> af0(22bit)+t(2bits)                                55~60(WORD 10)

% t = 2 NONINFORMATION BEARING BITS USED FOR PARITY COMPUTATION
% C = TLM BITS 23 AND 24 WHICH ARE RESERVED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EPH.GPSWeek = bitshift(hex2dec(remain{14}(13:15)), -2) + 1024*1;    % 현재 1 cycle(1~1023), TOE의 GPS Weeek
EPH.CodesOnL2Channel = bitand(hex2dec(remain{14}(15)), 3);
temp = hex2dec(remain{14}(16));URA = [2, 2.8, 4, 5.7, 8, 11.3, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 0];
EPH.SVAccuracy = URA(temp+1);                                   % IS-GPS-200D (unit: meter)
EPH.SVHealth = bitshift(hex2dec(remain{14}(17:18)), -2);
EPH.IODC = bitand(bitshift(hex2dec(remain{14}(17:18)), 8), 1023) + hex2dec(remain{14}(43:44));

EPH.L2PDataFlag = bitshift(hex2dec(remain{14}(19)), -3);

temp = hex2dec(remain{14}(41:42));
if(bitget(temp, 8))
    temp = temp - 2^7;
    EPH.TGD = 2^-31 * (temp-2^7);
else
    EPH.TGD = 2^-31 * temp;
end

EPH.TOC = 2^4 * hex2dec(remain{14}(45:48));
% temp = gps2utc([mod(EPH.GPSWeekT, 1024) EPH.TOC, 1], 0);        % leap seconds 0초 적용은 gps2gps 형태
temp = gps2utc([EPH.GPSWeek, EPH.TOC, 0], 0);       % 시간의 0은 1cycle 적용된 값이고, 옵션의 0은 leap seconds 0초 적용으로 gps2gps 형태임
EPH.TOCYear = temp(1);
EPH.TOCMonth = temp(2);
EPH.TOCDay = temp(3);
EPH.TOCHour = temp(4);
EPH.TOCMinute = temp(5);
EPH.TOCSecond = temp(6);

temp = hex2dec(remain{14}(49:50));
if(bitget(temp, 8))
    temp = temp - 2^7;
    EPH.af2 = 2^-55 * (temp-2^7);
else
    EPH.af2 = 2^-55 * temp;
end

temp = hex2dec(remain{14}(51:54));
if(bitget(temp, 16))
    temp = temp - 2^15;
    EPH.af1 = 2^-43 * (temp-2^15);
else
    EPH.af1 = 2^-43 * temp;
end

temp = hex2dec(remain{14}(55:60));
temp = bitshift(temp, -2);
if(bitget(temp, 22))
    temp = temp - 2^21;
    EPH.af0 = 2^-31 * (temp-2^21);
else
    EPH.af0 = 2^-31 * temp;
end

%%%%%%%%%% Subframe 2 %%%%%%%%%%
% 8b073c --> TLM(22bits)+C(2bits)	                            01~06(WORD 01)
% 8c9eab --> HOW(22bits)+t(2bits)                               07~12(WORD 02)
% 02fa2d --> IODE(8bits)+Crs(16bits)                            13~18(WORD 03)
% 30546f --> Delta_n(16bits)+Mo(8bits, MSBs)	                19~24(WORD 04)
% 81e15a --> M0(24bits, LSBs)                                   25~30(WORD 05)
% facb00 --> Cuc(16bits)+e(8bits, MSBs)                         31~36(WORD 06)
% 575009 --> e(24bits, LSBs)	                                37~42(WORD 07)
% 0c03a1 --> Cus(16bits)+squr_A(8bits, MSBs)	                43~48(WORD 08)
% 0d6af6 --> squr_A(24bits, LSBs)                               49~54(WORD 09)
% 6977   --> TOE(16bits)                                        55~58(WORD 10)
% 2c     --> FIT_INTERVAL_FLAG(1bits)+AODO(5bits)+t(2bits)	    59~60(WORD 10)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EPH.IODE = hex2dec(remain{15}(13:14));

temp = hex2dec(remain{15}(15:18));
if bitget(temp, 16)
    temp = temp - 2^15;
    EPH.Crs = 2^-5 * (temp - 2^15);
else
    EPH.Crs = 2^-5 * (temp);
end

temp = hex2dec(remain{15}(19:22));
if bitget(temp, 16)
    temp = temp - 2^15;
    EPH.Delta_n = 2^-43 * pi * (temp - 2^15);
else
    EPH.Delta_n = 2^-43 * pi * (temp);
end

temp = hex2dec(remain{15}(23:30));
if bitget(temp, 32)
    temp = temp - 2^31;
    EPH.M0 = 2^-31 * pi * (temp - 2^31);
else
    EPH.M0 = 2^-31 * pi * (temp);
end

temp = hex2dec(remain{15}(31:34));
if bitget(temp, 16)
    temp = temp - 2^15;
    EPH.Cuc = 2^-29 * (temp - 2^15);
else
    EPH.Cuc = 2^-29 * (temp);
end

EPH.e = 2^-33 * hex2dec(remain{15}(35:42));

temp = hex2dec(remain{15}(43:46));
if bitget(temp, 16)
    temp = temp - 2^15;
    EPH.Cus = 2^-29 * (temp - 2^15);
else
    EPH.Cus = 2^-29 * (temp);
end

EPH.sqrt_A = 2^-19 * hex2dec(remain{15}(47:54));

EPH.TOE = 2^4 * hex2dec(remain{15}(55:58));

EPH.FitInterval = bitshift(hex2dec(remain{14}(9)), -3);

%%%%%%%%%% Subframe 3 %%%%%%%%%%
% 8b073c --> TLM(22bits)+C(2bits)                               01~06(WORD 01)
% 8c9f2e --> HOW(22bits)+t(2bits)                               07~12(WORD 02)
% ffeb2f --> Cic(16bits)+OMEGA0(8bits, MSBs)                    16~18(WORD 03)
% 87a73e --> OMEGA0(24bits, LSBs)                               19~24(WORD 04)
% fff627 --> Cis(16bits)+iO(8bits, MSBs)                        25~30(WORD 05)
% 02c469 --> i0(24bits, LSBs)                                   31~36(WORD 06)
% 2173cd --> Crc(16bits)+omega(8bits, MSBs)                     37~42(WORD 07)
% 412fab --> omega(24bits, LSBs)                                43~48(WORD 08)
% ffa781 --> OMEGA_DOT(24bits, LSBs)                            49~54(WORD 09)
% 02ff9a --> IODE(8bits)+IODT(14bits)+t(2bits)	                55~60(WORD 10)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

temp = hex2dec(remain{16}(13:16));
if bitget(temp, 16)
    temp = temp - 2^15;
    EPH.Cic = 2^-29 * (temp - 2^15);
else
    EPH.Cic = 2^-29 * (temp);
end

temp = hex2dec(remain{16}(17:24));
if bitget(temp, 32)
    temp = temp - 2^31;
    EPH.OMEGA0 = 2^-31 * pi * (temp - 2^31);
else
    EPH.OMEGA0 = 2^-31 * pi * (temp);
end

temp = hex2dec(remain{16}(25:28));
if bitget(temp, 16)
    temp = temp - 2^15;
    EPH.Cis = 2^-29 * (temp - 2^15);
else
    EPH.Cis = 2^-29 * (temp);
end

EPH.i0 = 2^-31 * pi * hex2dec(remain{16}(29:36));

temp = hex2dec(remain{16}(37:40));
if bitget(temp, 16)
    temp = temp - 2^15;
    EPH.Crc = 2^-5 * (temp - 2^15);
else
    EPH.Crc = 2^-5 * (temp);
end

temp = hex2dec(remain{16}(41:48));
if bitget(temp, 32)
    temp = temp - 2^31;
    EPH.omega = 2^-31 * pi * (temp - 2^31);
else
    EPH.omega = 2^-31 * pi * (temp);
end

temp = hex2dec(remain{16}(49:54));
if bitget(temp, 24)
    temp = temp - 2^23;
    EPH.OMEGA_DOT = 2^-43 * pi * (temp - 2^23);
else
    EPH.OMEGA_DOT = 2^-43 * pi * (temp);
end

% EPH.IODE = hex2dec(remain{16}(55:56));      % 중복 데이터(Subframe 2의 WORD 3부분)

temp = bitshift(hex2dec(remain{16}(57:60)), -2);
if bitget(temp, 14)
    temp = temp - 2^13;
    EPH.IDOT = 2^-43 * pi * (temp-2^13);
else
    EPH.IDOT = 2^-43 * pi * (temp);
end

%%%%%%%%%% 검증용 데인터 %%%%%%%%%%
% clear

% packet_data = '#RAWEPHEMA,UNKNOWN,0,69.0,SATTIME,1487,431970.000,00000000,97b7,2945;9,1487,431984,8b073c8c9e2673d0007f1a6c9d6d8e7850c78b33f410697700000f009da3,8b073c8c9eab10fcf92e74cab4f700fe730a49dd9c105ea10d52b1697719,8b073c8c9f2e001259384d5600f62799ca281dae39ce45b5ffa8ca100ef0*a6025914';
% brdc1920.08n
%  9 08  7 10 23 59 44.0 0.469759106636E-05 0.170530256582E-11 0.000000000000E+00
%     0.160000000000E+02-0.242187500000E+02 0.424731977506E-08-0.130800961363E+01
%    -0.739470124245E-06 0.200948002748E-01 0.780448317528E-05 0.515366537666E+04
%     0.431984000000E+06 0.335276126862E-07 0.218978653756E+01 0.458210706711E-06
%     0.971948411861E+00 0.237437500000E+03 0.141876658697E+01-0.797390357366E-08
%     0.341442793891E-09 0.100000000000E+01 0.148700000000E+04 0.000000000000E+00
%     0.240000000000E+01 0.000000000000E+00-0.558793544769E-08 0.160000000000E+02
%     0.427236000000E+06 0.400000000000E+01 0.000000000000E+00 0.000000000000E+00

% EPH.PRN                = 9
% EPH.GPSWeekT           = 
% EPH.GPSSecT            = 0.427236000000E+06
% EPH.GPSWeek            = 0.148700000000E+04
% EPH.CodesOnL2Channel   = 0.100000000000E+01
% EPH.SVAccuracy         = 0.240000000000E+01
% EPH.SVHealth           = 0.000000000000E+00
% EPH.IODC               = 0.160000000000E+02
% EPH.L2PDataFlag        = 0.000000000000E+00
% EPH.TGD                = -0.558793544769E-08
% EPH.TOC                = 
% EPH.TOCYear            = 2008
% EPH.TOCMonth           = 7
% EPH.TOCDay             = 10
% EPH.TOCHour            = 23
% EPH.TOCMinute          = 59
% EPH.TOCSecond          = 44.0
% EPH.af2                = 0.000000000000E+00
% EPH.af1                = 0.170530256582E-11
% EPH.af0                = 0.469759106636E-05
% EPH.Crs                = -0.242187500000E+02
% EPH.Delta_n            = 0.424731977506E-08
% EPH.M0                 = -0.130800961363E+01
% EPH.Cuc                = -0.739470124245E-06
% EPH.e                  = 0.200948002748E-01
% EPH.Cus                = 0.780448317528E-05
% EPH.sqrt_A             = 0.515366537666E+04
% EPH.TOE                = 0.431984000000E+06
% EPH.Cic                = 0.335276126862E-07
% EPH.OMEGA0             = 0.218978653756E+01
% EPH.Cis                = 0.458210706711E-06
% EPH.i0                 = 0.971948411861E+00
% EPH.Crc                = 0.237437500000E+03
% EPH.omega              = 0.141876658697E+01
% EPH.OMEGA_DOT          = -0.797390357366E-08
% EPH.IODE               = 0.160000000000E+02
% EPH.IDOT               = 0.341442793891E-09

% packet_data = '#RAWEPHEMA,UNKNOWN,0,69.0,SATTIME,1487,431970.000,00000000,97b7,2945;15,1487,431984,8b073c8c9e2673d0007f1a6c9d6d8e7850c78b33eb02697700ffc9ed8ee3,8b073c8c9eab02fa2d30546f81e15afacb005750090c03a10d6af669772c,8b073c8c9f2effeb2f87a73efff62702c4692173cd412fabffa78102ff9a*31ffbc41';
% brdc1920.08n
% 15 08  7 10 23 59 44.0-0.140700489283E-03-0.625277607469E-11 0.000000000000E+00
%     0.200000000000E+01-0.465937500000E+02 0.441875548747E-08 0.273680199513E+01
%    -0.248290598392E-05 0.666142557748E-03 0.572763383389E-05 0.515367722702E+04
%     0.431984000000E+06-0.391155481339E-07 0.116655914876E+01-0.186264514923E-07
%     0.957469316223E+00 0.267593750000E+03-0.124547867397E+01-0.809140846821E-08
%    -0.928610108910E-11 0.100000000000E+01 0.148700000000E+04 0.000000000000E+00
%     0.240000000000E+01 0.000000000000E+00-0.977888703346E-08 0.200000000000E+01
%     0.424806000000E+06 0.400000000000E+01 0.000000000000E+00 0.000000000000E+00

% EPH.PRN                = 15
% EPH.GPSWeekT           = 
% EPH.GPSSecT            = 
% EPH.GPSWeek            = 0.148700000000E+04
% EPH.CodesOnL2Channel   = 0.100000000000E+01
% EPH.SVAccuracy         = 0.240000000000E+01
% EPH.SVHealth           = 0.000000000000E+00
% EPH.IODC               = 0.200000000000E+01
% EPH.L2PDataFlag        = 0.000000000000E+00
% EPH.TGD                = -0.977888703346E-08
% EPH.TOC                = 
% EPH.TOCYear            = 2008
% EPH.TOCMonth           = 7
% EPH.TOCDay             = 10
% EPH.TOCHour            = 23
% EPH.TOCMinute          = 59
% EPH.TOCSecond          = 44.0
% EPH.af2                = 0.000000000000E+00
% EPH.af1                = -0.625277607469E-11
% EPH.af0                = -0.140700489283E-03
% EPH.Crs                = -0.465937500000E+02
% EPH.Delta_n            = 0.441875548747E-08
% EPH.M0                 = 0.273680199513E+01
% EPH.Cuc                = -0.248290598392E-05
% EPH.e                  = 0.666142557748E-03
% EPH.Cus                = 0.572763383389E-05
% EPH.sqrt_A             = 0.515367722702E+04
% EPH.TOE                = 0.431984000000E+06
% EPH.Cic                = -0.391155481339E-07
% EPH.OMEGA0             = 0.116655914876E+01
% EPH.Cis                = -0.186264514923E-07
% EPH.i0                 = 0.957469316223E+00
% EPH.Crc                = 0.267593750000E+03
% EPH.omega              = -0.124547867397E+01
% EPH.OMEGA_DOT          = -0.809140846821E-08
% EPH.IODE               = 0.200000000000E+01
% EPH.IDOT               = -0.928610108910E-11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

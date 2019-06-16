%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DGPS ,Relative DGPS                            %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
prvec_SD = NST(1).DATAc(:,COL_DATA_C1C) - NST(2).DATAc(:,COL_DATA_C1C);
svxyzmat = NST(1).DATAc(:,COL_DATA_SVXYZ);

% 
NST(1).XYZB_RGPSSD = olspos_SD(prvec_SD, svxyzmat, RefPos);
NST(1).ENU_RGPSSD = ecef2enu(NST(1).XYZB_RGPSSD(1:3), RefPos);

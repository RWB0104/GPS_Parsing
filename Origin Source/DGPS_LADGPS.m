%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DGPS ,Local Area DGPS                          %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
prvec = NST(2).DATAc(:,COL_DATA_C1C);
svxyzmat = NST(2).DATAc(:,COL_DATA_SVXYZ);
temp_ref = repmat(RefPos, NPS.NoSVc, 1);

% 
PR = sqrt((svxyzmat(:,1) - temp_ref(:,1)).^2 + (svxyzmat(:,2) - temp_ref(:,2)).^2 + (svxyzmat(:,3) - temp_ref(:,3)).^2);
PRC = PR - prvec;

% 
prvec = NST(1).DATAc(:,COL_DATA_C1C) + PRC;
svxyzmat = NST(1).DATAc(:,COL_DATA_SVXYZ);
NST(1).XYZB_LADGPS = olspos(prvec, svxyzmat);
NST(1).ENU_LADGPS = ecef2enu(NST(1).XYZB_LADGPS(1:3), RefPos);

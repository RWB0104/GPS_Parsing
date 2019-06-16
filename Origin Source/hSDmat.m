%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% H (Single Difference)                          %
%                                                %
% Version: 1.0_20080901                          %
% Programmed by                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [delZ, H_SD] = hSDmat(DATA_usr, DATA_ref, ENU_usr, ENU_ref, ClockBias, Nhat, NoSVc)

global COL_DATA_L1C COL_DATA_SVENU

H_SD = ones(NoSVc, 4);

temp01 = DATA_usr(:, COL_DATA_SVENU) - repmat(ENU_usr, NoSVc, 1);
temp02 = sqrt(temp01(:, 1).^2 + temp01(:, 2).^2 + temp01(:, 3).^2);
temp03 = DATA_ref(:, COL_DATA_SVENU) - repmat(ENU_ref, NoSVc, 1);
temp04 = sqrt(temp03(:, 1).^2 + temp03(:, 2).^2 + temp03(:, 3).^2);

H_SD(:, 1) = -temp01(:, 1)./temp02;
H_SD(:, 2) = -temp01(:, 2)./temp02;
H_SD(:, 3) = -temp01(:, 3)./temp02;

delZ = (DATA_usr(:, COL_DATA_L1C) - DATA_ref(:, COL_DATA_L1C)) - (temp02 - temp04) - ClockBias - Nhat;

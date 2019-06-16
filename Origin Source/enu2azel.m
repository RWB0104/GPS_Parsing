function [az, el] = enu2azel(enu)
%   Input:
%      enu - vector in east, north and up coordinates (nx3)
%
%   Output:
%      az  - azimuth (rad) (nx1):  rotation of vector in local North-East
%            plane, clockwise positive beginning at North,  0 <= az < 2*pi
%      el  - elevation (rad) (nx1):  angle of vector above North-East plane,
%            positive for a vector with a negative down component   (i.e., 
%                positive up component), -pi/2 <= el <= pi/2

az = atan2(enu(:, 1), enu(:, 2));

I_neg_az = find(az < 0);

if ~isempty(I_neg_az)
    az(I_neg_az) = az(I_neg_az) + 2*pi;
end

north_east_mag = sqrt(enu(:,1).^2 + enu(:,2).^2);
el = atan2(enu(:,3), north_east_mag);

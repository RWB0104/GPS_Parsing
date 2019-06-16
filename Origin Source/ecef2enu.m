function [ENU] = ecef2enu(ecefpos, orgxyz)
%XYZ2ENU	Convert from WGS-84 ECEF cartesian coordinates to 
%               rectangular local-level-tangent ('East'-'North'-Up)
%               coordinates.
%
%	enu = XYZ2ENU(xyz,orgxyz)	
%    INPUTS
%	xyz(1) = ECEF x-coordinate in meters
%	xyz(2) = ECEF y-coordinate in meters
%	xyz(3) = ECEF z-coordinate in meters
%
%	orgxyz(1) = ECEF x-coordinate of local origin in meters
%	orgxyz(2) = ECEF y-coordinate of local origin in meters
%	orgxyz(3) = ECEF z-coordinate of local origin in meters
%
%    OUTPUTS
%       enu:  Column vector
%		enu(1,1) = 'East'-coordinate relative to local origin (meters)
%		enu(2,1) = 'North'-coordinate relative to local origin (meters)
%		enu(3,1) = Up-coordinate relative to local origin (meters)

xyz=[-3139627.57546918,4196451.49076154,3751476.50222665];

tmpxyz = ecefpos;
tmporg = orgxyz;

if size(tmpxyz) ~= size(tmporg)
    tmporg = tmporg';
end

difxyz = tmpxyz - repmat(tmporg, size(tmpxyz,1), 1);

[m, n] = size(difxyz);

orgllh = xyz2llh(orgxyz);
phi = orgllh(1);
lam = orgllh(2);
sinphi = sin(phi);
cosphi = cos(phi);
sinlam = sin(lam);
coslam = cos(lam);

R = [ -sinlam coslam  0 ; -sinphi*coslam  -sinphi*sinlam  cosphi ; cosphi*coslam   cosphi*sinlam  sinphi];
ENU = R*difxyz';
ENU = ENU';

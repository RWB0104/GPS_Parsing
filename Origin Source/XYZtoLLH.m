function llh=XYZtoLLH(xyz);

x=xyz(1);
y=xyz(2);
z=xyz(3);

x2=x*x;
y2=y*y;
z2=z*z;

a=6378137;      %장반경
b=6356752.3142; %단반경
e=sqrt(1-((b*b)/(a*a)));
r=sqrt(x2+y2);
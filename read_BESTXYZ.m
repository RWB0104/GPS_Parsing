function [data, xyz, user, time] = read_BESTXYZ(data)

[H, D]=strtok(data, ';');
D=strrep(D, ';', '');

Hscan=strread(H, '%s', 'delimiter', ',');
Dscan=strread(D, '%s', 'delimiter', ',');

t(1,1)=strread(Hscan{6}, '%f');
t(1,2)=strread(Hscan{7}, '%f')+32400;

time=gps2utc(t,0);

xyz(1,1)=strread(Dscan{3}, '%f');
xyz(1,2)=strread(Dscan{4}, '%f');
xyz(1,3)=strread(Dscan{5}, '%f');

user=ecef2lla(xyz);
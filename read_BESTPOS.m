function [data, user, time] = read_BESTPOS(data)

[H, D]=strtok(data, ';');
D=strrep(D, ';', '');

Hscan=strread(H, '%s', 'delimiter', ',');
Dscan=strread(D, '%s', 'delimiter', ',');

t(1,1)=strread(Hscan{6}, '%f');
t(1,2)=strread(Hscan{7}, '%f')+32400;

time=gps2utc(t,0);

user(1,1)=strread(Dscan{3}, '%f');
user(1,2)=strread(Dscan{4}, '%f');
user(1,3)=strread(Dscan{5}, '%f');
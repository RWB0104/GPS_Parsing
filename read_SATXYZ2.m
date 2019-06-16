function [data, sat, satpos, corr, time, code] = read_SATXYZ2(data)

[H, D]=strtok(data, ';');
D=strrep(D, ';', '');
satpos=zeros(35,3);
corr=zeros(35,3);

Hscan=strread(H, '%s', 'delimiter', ',');
Dscan=strread(D, '%s', 'delimiter', ',');

t(1,1)=strread(Hscan{6}, '%f');
t(1,2)=strread(Hscan{7}, '%f')+32400;

time=gps2utc(t,0);

sat=str2double(Dscan{1});

if isnan(sat) == 0
    
    for i=1:sat
        
        a(i,1)=str2double(Dscan{3+(i-1)*10});
        a(i,2)=str2double(Dscan{4+(i-1)*10});
        a(i,3)=str2double(Dscan{5+(i-1)*10});
        a(i,4)=str2double(Dscan{6+(i-1)*10});
        
        b(i,1)=str2double(Dscan{3+(i-1)*10});
        b(i,2)=str2double(Dscan{7+(i-1)*10});
        b(i,3)=str2double(Dscan{8+(i-1)*10});
        b(i,4)=str2double(Dscan{9+(i-1)*10});
        
    end
    
    code=1;
    
    sortrows(a);
    sortrows(b);
    
    for i=1:35
        
        for l=1:sat
            
            if i==a(l,1)
                
                satpos(i,1:3)=a(l,2:4);
                
            end
            
            if i==b(l,1)
                
                corr(i,1:3)=b(l,2:4);
                
            end
            
        end
        
    end
    
else
    
    corr=0;
    code=0;
    
end
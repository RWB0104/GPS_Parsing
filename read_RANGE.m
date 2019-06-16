function [data, real_sat, P, C, time, code] = read_RANGE(data)

[H, D]=strtok(data, ';');
D=strrep(D, ';', '');
P=zeros(35,3);
C=zeros(35,3);
l=1;

Hscan=strread(H, '%s', 'delimiter', ',');
Dscan=strread(D, '%s', 'delimiter', ',');

t(1,1)=strread(Hscan{6}, '%f');
t(1,2)=strread(Hscan{7}, '%f')+32400;

time=gps2utc(t,0);

sat=str2double(Dscan{1});

if isnan(sat) == 0
    
    for i=1:sat
        
        if i==1
            
            a(i,1)=str2double(Dscan{2+(i-1)*10});
            a(i,2)=str2double(Dscan{4+(i-1)*10});
            a(i,3)=0;
            b(i,1)=str2double(Dscan{2+(i-1)*10});
            b(i,2)=str2double(Dscan{6+(i-1)*10});
            b(i,3)=0;
            
        else
            
            if a(l,1)==str2double(Dscan{2+(i-1)*10})
                
                a(l,3)=str2double(Dscan{4+(i-1)*10});
                
            end
            
            if b(l,1)==str2double(Dscan{2+(i-1)*10})
                
                b(l,3)=str2double(Dscan{6+(i-1)*10});
                
            else
                
                a(l+1,1)=str2double(Dscan{2+(i-1)*10});
                a(l+1,2)=str2double(Dscan{4+(i-1)*10});
                a(l+1,3)=0;
                b(l+1,1)=str2double(Dscan{2+(i-1)*10});
                b(l+1,2)=str2double(Dscan{6+(i-1)*10});
                b(l+1,3)=0;
                
                l=l+1;
                
            end
            
        end
        
    end
    
    code=1;
    
    sortrows(a);
    sortrows(b);
    real_sat=size(a,1);
    
    for i=1:35
        
        for l=1:real_sat
            
            if i==a(l,1)
                
                P(i,:)=a(l,:);
                
            end
            
        end
            
    end
    
    P(:,1)=[];
    
    for i=1:35
        
        for l=1:real_sat
            
            if i==b(l,1)
                
                C(i,:)=b(l,:);
                
            end
            
        end
        
    end
    
    C(:,1)=[];
    
else
    
    code=0;
    real_sat=0;
    
end
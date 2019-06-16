function [estuser, dop] = LS_pos(num, satpos, p, corr, recent)

l=1;

if nargin < 5
    
    recent=[0, 0, 0, 0];
    
end

estuser=recent;

for i=1:35
    
    if (satpos(i,1) && satpos(i,2) && satpos(i,3) && p(i,1) && corr(i,1))
        
        m(l)=i;
        l=l+1;
        
    end
    
end

% p=geop-corr1+corr2+corr3

for N=1:num
    
    for i=1:l-1
        
        geoP(i,1)=norm(satpos(m(i),1:3)-estuser(1,1:3));
        %P(i,1)=geoP(i,1)-corr(m(i),1)+corr(m(i),2)+corr(m(i),3);
        
        a(i,1)=(estuser(1,1)-satpos(m(i),1))/geoP(i,1);
        a(i,2)=(estuser(1,2)-satpos(m(i),2))/geoP(i,1);
        a(i,3)=(estuser(1,3)-satpos(m(i),3))/geoP(i,1);
        a(i,4)=1;
        
        dp(i,1)=p(m(i),1)-geoP(i,1)+corr(m(i),1)-corr(m(i),2)-corr(m(i),3);
        dp(i,1)=dp(i,1)-estuser(1,4);
        
    end
    
    dpos=a\dp;
    estuser=estuser+dpos';
    
end

conv=inv(a'*a);
dop=sqrt(conv(1,1)+conv(2,2)+conv(3,3)+conv(4,4));
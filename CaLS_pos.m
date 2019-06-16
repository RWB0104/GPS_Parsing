function [estuser, prc] = CaLS_pos(num, freq, satpos, carry, corr, recent)

l=1;
L=299792458/freq;
carry=-(L*carry);


for i=1:35
    
    if (satpos(i,1) && satpos(i,2) && satpos(i,3) && carry(i,1) && corr(i,1))
        
        m(l)=i;
        l=l+1;
        
    end
    
end


a=zeros(l-1,(l-1)+4);

if nargin < 6
    
    recent=[0, 0, 0, 0];
    
end

estuser=[recent, zeros(1,l-1)];
% p=geop-corr1+corr2+corr3


for N=1:num
    
    for i=1:l-1
        
        geoP(i,1)=norm(satpos(m(i),1:3)-estuser(1,1:3));
        %P(i,1)=geoP(i,1)-corr(m(i),1)+corr(m(i),2)+corr(m(i),3);
        
        a(i,1)=(estuser(1,1)-satpos(m(i),1))/geoP(i,1);
        a(i,2)=(estuser(1,2)-satpos(m(i),2))/geoP(i,1);
        a(i,3)=(estuser(1,3)-satpos(m(i),3))/geoP(i,1);
        a(i,4)=1;
        a(i,i+4)=L;
        
        dp(i,1)=carry(m(i),1)-geoP(i,1)+corr(m(i),1)-corr(m(i),2)-corr(m(i),3);
        %dp(i,1)=dp(i,1)+estuser(1,i+4)-estuser(1,4);
        
    end
    
    dpos=a\dp;
    estuser=estuser+dpos';
    
end

estuser=estuser(1:4);

prc=zeros(35,1);
o=1;

for i=1:l-1
    
   prc(m(i))=dp(o);
   o=o+1;
    
end
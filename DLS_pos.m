function [estuser, prc] = DLS_pos(num, satpos, p, corr, Dp, DgeoP, Dcorr, Dprc, recent)

l=1;

if nargin < 9
    
    recent=[0, 0, 0, 0];
    
end

estuser=recent;

for i=1:35
    
    if (satpos(i,1) && satpos(i,2) && satpos(i,3) && p(i,1) && corr(i,1) && Dp(i,1) && DgeoP(i,1) && Dcorr(i,1) && Dprc(i,1))
        
        m(l)=i;
        l=l+1;
        
    end
    
end

for N=1:num
    
    for i=1:l-1
        
        geoP(i,1)=norm(satpos(m(i),1:3)-estuser(1,1:3));
        
        a(i,1)=(estuser(1,1)-satpos(m(i),1)) / geoP(i,1);
        a(i,2)=(estuser(1,2)-satpos(m(i),2)) / geoP(i,1);
        a(i,3)=(estuser(1,3)-satpos(m(i),3)) / geoP(i,1);
        a(i,4)=1;
        
        %dp(i,1)=p(m(i),1)-geoP(i,1)-estuser(1,4)+corr(m(i),1)-corr(m(i),2)-corr(m(i),3);
        dp(i,1)=p(m(i),1)-Dp(m(i),1)-(geoP(i,1)-DgeoP(m(i),1))+(corr(m(i),1)-Dcorr(m(i),1))-(corr(m(i),2)-Dcorr(m(i),2))-(corr(m(i),3)-Dcorr(m(i),3))-Dprc(m(i),1);
        dp(i,1)-dp(i,1)-estuser(1,4);
        
    end
    
    dpos=a\dp;
    
    estuser=estuser+dpos';
    
end

prc=zeros(35,1);
o=1;

for i=1:l-1
    
   prc(m(i))=dp(o);
   o=o+1;
    
end
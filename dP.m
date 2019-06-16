function msg = dP(num, satpos, p, corr)

l=1;

estuser=recent;

for i=1:35
    
    if (satpos(i,1) && satpos(i,2) && satpos(i,3) && p(i,1) && corr(i,1))
        
        m(l)=i;
        l=l+1;
        
    end
    
end

for N=1:num
    
    for i=1:l-1
        
        geoP(i,1)=norm(satpos(m(i),1:3)-estuser(1,1:3));
        
        a(i,1)=(estuser(1,1)-satpos(m(i),1))/geoP(i,1);
        a(i,2)=(estuser(1,2)-satpos(m(i),2))/geoP(i,1);
        a(i,3)=(estuser(1,3)-satpos(m(i),3))/geoP(i,1);
        a(i,4)=1;
        
        dp(i,1)=p(m(i),1)-geoP(i,1)+corr(m(i),1)-corr(m(i),2)-corr(m(i),3);
        
    end
    
    dpos=a\dp;
    
    estuser=estuser+dpos';
    
    Dp=norm(dp);
    
    msg=[l-1, Dp]
    
end
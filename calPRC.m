function [prc, realP, mi] = calPRC(xyz, satpos, p, corr, base)

if nargin < 5
    
    base=[-3073914.4265,4088898.3051,3796975.3448];
    
end


PRC=zeros(35,1);

for i=1:35
    
    if (satpos(i,1) && satpos(i,2) && satpos(i,3) && p(i,1) && corr(i,1))
        
        realP(i,1)=norm(satpos(i,1:3)-base(1,1:3));
        %prc(i,1)=p(i,1)-realP(i,1)+corr(i,1)-corr(i,2)-corr(i,3);
        %prc(i,1)=p(i,1)-realP(i,1);
        
        prc(i,1)=realP(i,1)-p(i,1)+corr(i,2);
        
    end
    
end
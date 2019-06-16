function estuser = DLS_pos3(num, satpos, rp, rgeop, rcorr, bp, bgeop, bcorr, bprc, pos)

l=1;
estuser=[0,0,0,0];
% estuser=pos;

for i=1:35
    
    if (satpos(i,1) && satpos(i,2) && satpos(i,3) && rp(i,1) && rcorr(i,1) && bp(i,1) && bcorr(i,1) && bprc(i,1))
        
        m(l)=i;
        l=l+1;
        
    end
    
end

l=l-1;

for N=1:num
    
    for i=1:l
        
        geop(i,1)=norm(satpos(m(i),1:3)-estuser(1,1:3));
        
        bL(i,1)=bp(m(i),1)-bgeop(m(i),1)+bcorr(m(i),1)-bcorr(m(i),2)-bcorr(m(i),3)-bprc(m(i),1);
        
        %rL(i,1)=rp(m(i),1)-rgeop(m(i),1)+rcorr(m(i),1)-rcorr(m(i),2)-rcorr(m(i),3)-estuser(1,4);
        rL(i,1)=rp(m(i),1)-geop(i,1)+rcorr(m(i),1)-rcorr(m(i),2)-rcorr(m(i),3)-estuser(1,4);
        
        sd(i,1)=bgeop(m(i),1)-geop(i,1);
        
    end
    
    for i=1:l-1
        
        %dL(i,1)=(bL(i+1,1)-rL(i+1,1))-(bL(i,1)-rL(i,1));
        dL(i,1)=(bL(i+1,1)-rL(i+1,1))-(bL(i,1)-rL(i,1));
        
        a(i,1)=((estuser(1,1)-satpos(m(i+1),1))/sd(i+1,1))-((estuser(1,1)-satpos(m(i),1))/sd(i,1));
        a(i,2)=((estuser(1,2)-satpos(m(i+1),2))/sd(i+1,1))-((estuser(1,2)-satpos(m(i),2))/sd(i,1));
        a(i,3)=((estuser(1,3)-satpos(m(i+1),3))/sd(i+1,1))-((estuser(1,3)-satpos(m(i),3))/sd(i,1));
        a(i,4)=1;
        
        dpos=a\dL;
        estuser=estuser+dpos';
        
    end
    
end
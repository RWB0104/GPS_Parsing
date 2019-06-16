function estusr = olspos_SD(prvec_SD,svxyzmat,refpos,initpos,tol)

if nargin<5,tol=1e-3;end
if nargin<4,initpos=[0 0 0 0];end
if nargin<3,error('insufficient number of input arguments'),end
[m,n]=size(initpos);
if m>n, estusr=initpos';else estusr=initpos;end
if max(size(estusr))<3,
   error('must define at least 3 dimensions in INITPOS')
end
if max(size(estusr))<4,estusr=[estusr 0];end
numvis=max(size(svxyzmat));
beta=[1e9 1e9 1e9 1e9];
maxiter=10;
iter=0;
while ((iter<maxiter)&&(norm(beta)>tol)),
    y = zeros(numvis,1);
    for N = 1:numvis
        pr0_SD = norm(svxyzmat(N,:) - estusr(1:3)) - norm(svxyzmat(N,:) - refpos(1:3));
        y(N,1) = prvec_SD(N) - pr0_SD - estusr(4);
    end
    H = hmat(svxyzmat,estusr(1:3));
    beta = H\y;
    estusr=estusr+beta';
    iter=iter+1;
end

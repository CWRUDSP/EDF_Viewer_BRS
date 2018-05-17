% This function is to compute the Lomb-Scargle normalized periodogram for
% unevenly sampled time series. The algorithm adapted from "Fast algorithm
% for special analysis of unevenly sampled data" by william H. Press.
% Inputs:
%           X: abscissas or time points
%           Y: Ordinates or signal values at each data point
% Output:
%           WK1: sequnce of frequncy up to HIFAC times of average Nyquist
%           Freq. (The defualt values of HIFAC is 1).
%           Wk2: Values of Lomb Periodogram at each frequency
%           JMAX: the index of maximum value of WK2
%           PROB: a samll value of PROB indicates that a significant
%           periodic signal is present
% Developed By: Reza Jamasebi and Ravishankar Balaji
% Last Modified: Feb 26, 2008

function [WK1 WK2 JMAX PROB]=FASPER(X,Y)
%times the  Average Nyquist Freq.
HIFAC=1;
%Over Sampling Factor (Typically 4)
OFAC=4;
% The number of Data points
N=length(Y);
% Number of Interpolation points per 1/4 cycle of highest frequncy
MACC=2;
% Size the FFT as next power of 2 above Nyquist Freq.
NOUT=.5*OFAC*HIFAC*N;
NFREQT=OFAC*HIFAC*N*MACC;
NFREQ=64;
while NFREQ<NFREQT
    NFREQ=2*NFREQ;
end
NDIM=2*NFREQ;
AVE_Y=mean(Y);
VAR_Y=var(Y);
XMIN=min(X);
XMAX=max(X);
XDIF=range(X);
WK1=zeros(1,NDIM);
WK2=zeros(1,NDIM);
FAC1=NDIM/(XDIF*OFAC);
FNDIM=NDIM;
YAVE=Y-mean(Y);
NFAC=[1 1 2 6 24 120 720 5040 40320 362880];
for j=1:N
    CK=1+mod((X(j)-XMIN)*FAC1,FNDIM);
    CKK=1+mod(2*(CK-1),FNDIM);
    if round(CK)==CK
        WK1(CK)=WK1(CK)+YAVE(j);
    else
        IL0=min(max(floor(CK-.5*MACC+1),1),NDIM-MACC+1);
        IHI=IL0+MACC-1;
        NDEN=NFAC(MACC);
        FAC=CK-IL0;
        for jj=IL0+1:IHI;
            FAC=FAC*(CK-jj);
        end
        WK1(IHI)= WK1(IHI)+YAVE(j)*FAC/(NDEN*(CK-IHI));
        for jj=IHI-1:-1:IL0
            NDEN=(NDEN/(jj+1-IL0))*(jj-IHI);
            WK1(jj)=WK1(jj)+YAVE(j)*FAC/(NDEN*(CK-jj));
        end
    end
    if round(CKK)==CKK
        WK2(CKK)=WK2(CKK)+1;
    else
        IL0=min(max(floor(CKK-.5*MACC+1),1),NDIM-MACC+1);
        IHI=IL0+MACC-1;
        NDEN=NFAC(MACC);
        FAC=CKK-IL0;
        for jj=IL0+1:IHI;
            FAC=FAC*(CKK-jj);
        end
        WK2(IHI)= WK2(IHI)+1*FAC/(NDEN*(CKK-IHI));
        for jj=IHI-1:-1:IL0
            NDEN=(NDEN/(jj+1-IL0))*(jj-IHI);
            WK2(jj)=WK2(jj)+1*FAC/(NDEN*(CKK-jj));
        end
    end
end
WK1=abs(fftshift(fft(WK1)));
WK2=abs(fftshift(fft(WK2)));
WK1=WK1(NFREQ+1:2*NFREQ);
WK2=WK2(NFREQ+1:2*NFREQ);
DF=1/(XDIF*OFAC);
K=3;
PMAX=-1;
for j=1:NOUT
    HYPO=sqrt(WK2(K)^2+WK2(K+1)^2);
    HC2WT=.5*WK2(K)/HYPO;
    HS2WT=.5*WK2(K+1)/HYPO;
    CWT=sqrt(.5+HC2WT);
    SWT=sqrt(.5-HC2WT)*sign(HS2WT);
    DEN=.5*N+HC2WT*WK2(K)+HS2WT*WK2(K+1);
    CTERM=(CWT*WK1(K)+SWT*WK1(K+1))^2/DEN;
    STERM=(CWT*WK1(K)+SWT*WK1(K))^2/(N-DEN);
    WK1(j)=j*DF;
    WK2(j)=(CTERM+STERM)/(2*VAR_Y);
    if (WK2(j)>PMAX)
        PMAX=WK2(j);
        JMAX=j;
    end
    K=K+2;
end
EXPY=exp(-PMAX);
EFFM=2*NOUT/OFAC;
PROB=EFFM*EXPY;
if PROB>.01
    PROB =1-(1-EXPY)^EFFM;
end
WK1=2*WK1;
WK1=WK1(1:NOUT/2);
WK2=WK2(1:NOUT/2);
end

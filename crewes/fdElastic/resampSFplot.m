function [factt,indX,Xarr,indT,Tarr,DtPh,SFfile] = ....
        resampSFplot(spMin,nSpf,Dxz,tMin,Dt,nStep)
% function [factt,indX,Xarr,indT,Tarr,DtPh,SFfile] = ....
%         resampSFplot(spMin,nSpf,Dxz,tMin,Dt,nStep)
    %Change trace selection parameters from a menu here,
        % set resample vectors
    % Mostly copied from resampSEGY
%The input parameters are
    %spMin ... The offset or depth of the first available trace
    %nSpf .... The number of traces available
    %Dxz ..... Spatial sample rate
    %tMin .... Now zero
    %Dt   .... FD sample rate in seconds
    %nStep ... The number of time steps
%The output parameters are
    %factt ... The chosen amplitude factor
    %indX .... The index array of the chosen traces
    %Xarr .... The offset or depth array of the chosen traces
    %indT .... The index array of the chosen times
    %Tarr .... The time array of the chosen traces
    %DtPh .... The time interval of the chosen traces
    %SFfile .. The chosen unique part of a tif file name
%
% P.M. Manning, Dec 2011
%
% NOTE: It is illegal for you to use this software for a purpose other
% than non-profit education or research UNLESS you are employed by a CREWES
% Project sponsor. By using this software, you are agreeing to the terms
% detailed in this software's Matlab source file.
 
% BEGIN TERMS OF USE LICENSE
%
% This SOFTWARE is maintained by the CREWES Project at the Department
% of Geology and Geophysics of the University of Calgary, Calgary,
% Alberta, Canada.  The copyright and ownership is jointly held by 
% its author (identified above) and the CREWES Project.  The CREWES 
% project may be contacted via email at:  crewesinfo@crewes.org
% 
% The term 'SOFTWARE' refers to the Matlab source code, translations to
% any other computer language, or object code
%
% Terms of use of this SOFTWARE
%
% 1) Use of this SOFTWARE by any for-profit commercial organization is
%    expressly forbidden unless said organization is a CREWES Project
%    Sponsor.
%
% 2) A CREWES Project sponsor may use this SOFTWARE under the terms of the 
%    CREWES Project Sponsorship agreement.
%
% 3) A student or employee of a non-profit educational institution may 
%    use this SOFTWARE subject to the following terms and conditions:
%    - this SOFTWARE is for teaching or research purposes only.
%    - this SOFTWARE may be distributed to other students or researchers 
%      provided that these license terms are included.
%    - reselling the SOFTWARE, or including it or any portion of it, in any
%      software that will be resold is expressly forbidden.
%    - transfering the SOFTWARE in any form to a commercial firm or any 
%      other for-profit organization is expressly forbidden.
%
% END TERMS OF USE LICENSE
DtPhR = Dt*1000;
factt = 1.5;
tZero = tMin; phSp = Dxz; nPh = nSpf; DtPh = 5; %phMax = spMin+nSpf*Dxz;

phMin = spMin; spMax = spMin+Dxz*nSpf; nPhMax = nSpf;
SFfile = ''; %'default';
  str1 = 'SF parameters';
  str6 = ['First time = ',num2str(tZero)];
  str7 = ['Time int. (ms) = ',num2str(DtPh)];
  str9 = ['File name = ',SFfile];
  str99 = 'All OK';
kOptn = 0;
while kOptn < 7
    str3 = ['First phone = ',num2str(phMin)];
    str4 = ['Phone space. = ',num2str(phSp)];
    str5 = ['No. of phones. = ',num2str(nPh)];
    str8 = ['Amplitude = [',num2str(factt),']'];
    kOptn = menu(str1,str3,str4,str5,str6,str7,str8,str9,str99);
    if kOptn==1
        phMin = input('Type first position ');
        %str3 = ['First phone = ',num2str(phMin)];
        if (phMin<spMin)
            phMin = spMin;
        end
        nPhMax = floor((spMax-phMin)/phSp)+1;
    end
    if kOptn==2
        phSp = input('Type phone spacing ');
            nPhMax = floor((spMax-phMin)/phSp)+1;
    end
    if kOptn==3
        nPh = input('Type no. of phones ');
        if nPh > nPhMax
            nPh = nPhMax;
        end
    end
    if kOptn==4
        tZero = input('Type first time ');
        str6 = [' First time = ',num2str(tZero)];
    end
    if kOptn==5
        DtPh = input('Type time sample rate (ms)');
        %str7 = ['Delta t (ms) = ',num2str(DtPh)];
        str7 = ['Time int. (ms) = ',num2str(DtPh)];
    end
    if kOptn==6
        factt = input('Type amplitude ');                   %Amp
    end
    if kOptn==7
        SFfile = input('Name the SF file ','s');
        str9 = ['File name = ',SFfile];
    end
    if nPh>nPhMax 
        nPh = nPhMax;
    end
end
    %disp([phMin nPh phSp])
indX = zeros(nPh,1);    %Indices to select in X
Xarr = zeros(nPh,1);
for iPh = 1:nPh
    pos = phMin+(iPh-1)*phSp;
    indX(iPh) = round((pos-spMin)/Dxz)+1;
    %disp(indX(iPh))
    Xarr(iPh) = pos;
end
tMax = tMin+nStep*DtPhR;
nTsamp = round((tMax-tZero)/DtPh);
indT = zeros(nTsamp,1);    %Indices to select in time
Tarr = zeros(nTsamp,1);
for iTime = 1:nTsamp
    time = tZero+(iTime-1)*DtPh;
    indT(iTime) = round((time-tMin)/DtPhR)+1;
    Tarr(iTime) = time;
end
%disp(Xarr)

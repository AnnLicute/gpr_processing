function [pressure_out]=spatial_derivs_order4(pressure,logdensity,delx)
% spatial_derivs_order4 ... fourth order spatial derivatives for acoustic propagator
% 
% [output]=spatial_derivs_order4(pressure,logdensity,delx)
%
% spatial_derivs_order4 computes the fourth order approximation of the spatial
% derivative term of the acoustic wave equation.  This is
% Laplacian(pressure)-grad(logdensity)_dot_grad(pressure).  The horizontal
% and vertical bin spacing of both matrices MUST be the same and equal.
%
% pressure = input pressure matrix
% logdensity = input logdensity matrix
% delx = the horizontal/ vertical bin spacing in consistent units
%
% pressure_out = output pressure matrix
%
% by Carris Youzwishen, April 1999
% extended to full acoustic wave equation by Gary Margrave, Feb 2014
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

[nrows,ncolumns]=size(pressure);

pres=zeros(nrows+4,ncolumns+4);
pres(3:nrows+2,3:ncolumns+2)=pressure;
% pres(1,:)=pres(3,:);%fill extra row on top
% pres(2,:)=pres(3,:);%fill extra row on top
%NOTE: Flooding the top extra rows with live data values causes a very
%strong surface wave. Better to leave them zero. I think this may have
%something to do with boundary conditions.
pres(end-1,:)=pres(end-2,:);%fill extra row on bottom
pres(end,:)=pres(end-2,:);%fill extra row on bottom
pres(:,1)=pres(:,3);%fill extra column on left
pres(:,2)=pres(:,3);%fill extra column on left
pres(:,end-1)=pres(:,end-2);%fill extra column on right
pres(:,end)=pres(:,end-2);%fill extra column on right
dens=zeros(nrows+4,ncolumns+4);%new density matrix
dens(3:nrows+2,3:ncolumns+2)=logdensity;%fill
dens(1,:)=dens(3,:);%extra row on top
dens(2,:)=dens(3,:);%extra row on top
dens(end-1,:)=dens(end-2,:);%extra row on bottom
dens(end,:)=dens(end-2,:);%extra row on bottom
dens(:,1)=dens(:,3);%extra column on left
dens(:,2)=dens(:,3);%extra column on left
dens(:,end-1)=dens(:,end-2);%extra column on right
dens(:,end)=dens(:,end-2);%extra column on right
factor=1/(delx^2);%precompute factor
clear pressure
clear logdensity

%fourth order laplacian
% for first dimension

  pressure_out = (-pres(1:nrows,3:ncolumns+2) + 16*pres(2:nrows+1,3:ncolumns+2) ...
                 -30*pres(3:nrows+2,3:ncolumns+2) + 16*pres(4:nrows+3,3:ncolumns+2) ... 
                 -pres(5:nrows+4,3:ncolumns+2))/(12*delx^2);

% for second dimension 

 pressure_out = (-pres(3:nrows+2,1:ncolumns) + 16*pres(3:nrows+2,2:ncolumns+1) ...
                 -30*pres(3:nrows+2,3:ncolumns+2) + 16*pres(3:nrows+2,4:ncolumns+3) ... 
                 -pres(3:nrows+2,5:ncolumns+4))/(12*delx^2) + pressure_out;
%grad(logdensity)_dot_grad(pressure)
   factor=factor/144;
%first dimension
   pressure_out=pressure_out - ...
       ((dens(1:nrows,2:ncolumns+1)-8*dens(2:nrows+1,2:ncolumns+1)+8*dens(4:nrows+3, 2:ncolumns+1)-dens(5:nrows+4, 2:ncolumns+1)).*...
       (pres(1:nrows,2:ncolumns+1)-8*pres(2:nrows+1,2:ncolumns+1)+8*pres(4:nrows+3, 2:ncolumns+1)-pres(5:nrows+4, 2:ncolumns+1)))*factor;
%second dimension
   pressure_out=pressure_out - ...
       ((-dens(2:nrows+1,5:ncolumns+4)+8*dens(2:nrows+1,4:ncolumns+3)-8*dens(2:nrows+1,2:ncolumns+1)+dens(2:nrows+1,1:ncolumns)).*...
       (-pres(2:nrows+1,5:ncolumns+4)+8*pres(2:nrows+1,4:ncolumns+3)-8*pres(2:nrows+1,2:ncolumns+1)+pres(2:nrows+1,1:ncolumns)))*factor;


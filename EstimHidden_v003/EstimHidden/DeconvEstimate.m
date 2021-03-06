function [estimate,Obs] = DeconvEstimate(Z,W0,s0,Y)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is part of the package EstimHidden devoted to the estimation of 
%
% 1/ the density of X in a convolution model where Z=X+noise1 is observed 
%
% 2/ the functions b (drift) and s^2 (volatility) in an "errors in variables" 
%    model where Z and Y are observed and assumed to follow:
%           Z=X+noise1 and Y=b(X)+s(X)*noise2.
%
% 3/ the functions b (drift) and s^2 (volatility) in an stochastic
%    volatility model where Z is observed and follows:
%           Z=X+noise1 and X_{i+1} = b(X_i) + s(X_i)*noise2
%
% in any cases the density of noise1 is known. We consider three cases for
% this density : Gaussian ('normal'), Laplace ('symexp') and log(Chi2)
% ('logchi2)
%
% See function DeconvEstimate.m and examples in files ExampleDensity.m and
% ExampleRegression.m
%
% Authors : F. COMTE and Y. ROZENHOLC 
%
%
% For more information, see the following references:
%
% DENSITY DECONVOLUTION
%%%%%%%%%%%%%%%%%%%%%%%
%
% 1/ "Penalized contrast estimator for density deconvolution", 
%    The Canadian Journal of Statistics, 34, 431-452, 2006.
%    b y  F .  C O M T E ,  Y .  R O Z E N H O L C ,  and M . - L .  T A U P I N 
%
% 2/ "Finite sample  penalization in adaptive density deconvolution", 
%    Journal of Statistical Computation and Simulation. 
%    Available online.
%    b y  F .  C O M T E ,  Y .  R O Z E N H O L C ,  and M . - L .  T A U P I N 
%
% 3/ "Adaptive density estimation for general ARCH models", 
%    Preprint HAL-CNRS : hal-00101417  at http://hal.archives-ouvertes.fr/
%    b y  F .  C O M T E ,  J. DEDECKER, and  M . - L .  T A U P I N . 
%
% REGRESSION and AUTO-REGRESSION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 4/ "Nonparametric estimation of the regression function in an
%    errors-in-variables model", 
%    Statistica Sinica, 17, n�3, 1065-1090, 2007. 
%    b y  F .  C O M T E  and M . - L .  T A U P I N 
%
% 5/ "Adaptive estimation of the dynamics of a discrete time stochastic
%    volatility model", 
%    Preprint HAL-CNRS : hal-00170740 at http://hal.archives-ouvertes.fr/
%    by F .  C O M T E, C. LACOUR, and Y. R O Z E N H O L C . 
%
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %
 % Y o u  c a n  u s e  t h i s  s o f t w a r e  f o r  N O N - C O M M E R C I A L  U S E  O N L Y .  
 %
 % Y o u  c a n  d i s t r i b u t e  t h i s  s o f w a r e  u n c h a n g e d  a n d  o n l y  u n c h a n g e d ,  w h i c h  i m p l i e s 
 % i n c l u d i n g  a l l  f i l e s  f o u n d  i n  t h e  f o l d e r  c o i n t a i n n i n g  t h i s  f i l e . 
 %
 % T h i s  s o f t w a r e ,  a n d  a n y  p a r t  o f  i t ,  i s  p r o p o s e d  f o r  N O N - C O M M E R C I A L  U S E  
 % O N L Y .  
 %
 % P l e a s e ,  c o n t a c t  t h e  a u t h o r  f o r  a n d  b e f o r e  a n y  n o n - a c a d e m i c  u s e 
 % o f  t h i s  s o f t w a r e . 
 %
 % T o  r e p r o d u c e  t h i s  c o d e  o r  a n y  p a r t  o f  t h i s  c o d e  i n  t h e  o r i g i n a l  l a n g u a g e  
 % o r  i n  a n y  o t h e r  l a n g u a g e ,  f o r  c o m m e r c i a l  u s e ,  p l e a s e  c o n t a c t  t h e  A u t h o r 
 %
 % F o r  a c a d e m i c  p u r p o s e ,  c i t e  this package and t h e  c o n n e c t e d  p a p e r s . 
 %
 % C o r r e s p o n d i n g  a u t h o r  :  Y .  R o z e n h o l c ,  y v e s . r o z e n h o l c @ u n i v - p a r i s 5 . f r 
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Examples in files ExampleDensity.m and ExampleRegression.m
% 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 


if nargin<4, Y=NaN; end % ->> Density case

if nargin==1, 
    Obs = Z;
else
    Obs.Z=Z(:); Obs.W0=lower(W0); Obs.s0=s0; Obs.Y=Y; 
end


switch(lower(Obs.W0))
    case 'logchi2', Obs.W0 = 'logchi2';
	case {'symexp','laplace'}, Obs.W0 = 'symexp';
	case {'gaussian','normal'}, Obs.W0 = 'normal'; disp('Gaussian type')
    otherwise
        disp('unknown noise type')
end;

global lesZ lesY

n = length(Obs.Z);
M = 8;

% coef for g + associated contrast
lesZ = Obs.Z; lesY = ones(size(lesZ));
found = 0;
Dmin = log(n)^1.25/n/pi; Dmax = log(n)^1.25/pi;
while ~found
    Dtab = linspace(Dmin,Dmax,100);

    penCtr = DeconvPenCtr(Dtab,Obs.W0,Obs.s0^2,M,1);
    [minPenCtr,ind] = min(penCtr)

    % Density estimator parameters
    estimate.Dgopt = Dtab(ind);
    
    % test if we are on the border
    if (estimate.Dgopt<3/4*Dmin+1/4*Dmax), Dmax=(Dmin+Dmax)/2, continue; end
    if (estimate.Dgopt>1/4*Dmin+3/4*Dmax), Dmax=2*Dmax, continue; end
    
    % Dimension is OK
    found = 1;
end
    
% Density estimator parameters
estimate.gD = CoefConv(Obs.W0,estimate.Dgopt,M,Obs.s0);
estimate.n = n;
estimate.M = M;

estimate.Dlopt = nan; 

%%%%%%%%%%%%%% REGRESSION CASE ONLY !!!! %%%%%%%%%%%%%%%%%

if ~isnan(Obs.Y), % ->> Regression case
    
    disp('(auto)-Regression case')
    % on tri les Z
    [Z,I] = sort(Obs.Z); % OBSERVABLE
    % on trie les Y dans le meme ordre que les Z !!!
    Y = Obs.Y(I);

    % coef for l=fg + associated contrast
    lesZ = Z; lesY = Y; EY2 = mean(lesY.^2);
    found = 0;
    Dmin = log(n)^1.25/n/pi; Dmax = log(n)^1.25/pi;
    while ~found
        Dtab = linspace(Dmin,Dmax,100);

        penCtr = DeconvPenCtr(Dtab,Obs.W0,Obs.s0^2,M,EY2);
        [minPenCtr,ind] = min(penCtr)

        % Regression estimator parameters
        estimate.Dlopt = Dtab(ind);

        % test if we are on the border
        if (estimate.Dlopt<3/4*Dmin+1/4*Dmax), Dmax=(Dmin+Dmax)/2, continue; end
        if (estimate.Dlopt>1/4*Dmin+3/4*Dmax), Dmax=2*Dmax, continue; end

        % Dimension is OK
        found = 1;
    end

    % Regression estimator parameters
    estimate.lD = CoefConv(Obs.W0,estimate.Dlopt,M,Obs.s0);

    % coef for v=(s2+f2)*g + associated contrast
    lesY = Y.^2-Obs.s0^2; EY2 = mean(lesY.^2);
    found = 0;
    Dmin = log(n)^1.25/n/pi; Dmax = log(n)^1.25/pi;
    while ~found
        Dtab = linspace(Dmin,Dmax,100);

        penCtr = DeconvPenCtr(Dtab,Obs.W0,Obs.s0^2,M,EY2);
        [minPenCtr,ind] = min(penCtr)

        % Regression estimator parameters
        estimate.Dvopt = Dtab(ind);

        % test if we are on the border
        if (estimate.Dvopt<3/4*Dmin+1/4*Dmax), Dmax=(Dmin+Dmax)/2, continue; end
        if (estimate.Dvopt>1/4*Dmin+3/4*Dmax), Dmax=2*Dmax, continue; end

        % Dimension is OK
        found = 1;
    end

    estimate.vD = CoefConv(Obs.W0,estimate.Dvopt,M,Obs.s0);
end

%%%%%%%%%%%%%% DEFAULT ORDINATES in range min max %%%%%%%%%%%%%%%%%
sZ = sort(Obs.Z);

estimate = DeconvOrd(estimate,linspace(sZ(round(n*0.05)),sZ(round(n*0.95)),1001));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Part of DensityDeconvolution Project, author Yves ROZENHOLC
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% You can use this software for NON-COMMERCIAL USE ONLY. 
%
% You can distribute this sofware unchanged and only unchanged, which implies
% including all files found in the folder cointainning this file.
%
% This software, and any part of it, is proposed for NON-COMMERCIAL USE 
% ONLY. 
%
% Please, contact the author for and before any non-academic use
% of this software.
%
% To reproduce this code or any part of this code in the original language 
% or in any other language, for commercial use, please contact the Author
%
% For academic purpose, cite the connected papers.
%
% Corresponding author : Y. Rozenholc, yves.rozenholc@univ-paris5.fr
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


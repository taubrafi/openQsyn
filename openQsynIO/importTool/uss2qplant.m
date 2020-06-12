function [qp__] = uss2qplant(SS__)
%qplant2uss - Converts a uss in Robust Control Toolbox to a qplant in openQsyn
%
% Syntax:  [qp] = uss2qplant(SS)
%
% Inputs:
%    SS - The uss to convert
%
% Outputs:
%    qp - The output qplant
%
% Example:
%   %% Plant from openQsyn
%   k=qpar('k',2,2,5,8);
%   a=qpar('a',3,1,3,8);
%   z=qpar('z',0.6,0.3,0.6,8);
%   wn=qpar('wn',4,4,8,8);
%   num = [k*wn*wn k*wn*wn*a];
%   den = [1 2*z*wn wn*wn];
%   P = qplant(num,den);
%
%   %% Unstructured uncertainty
%   w = [0.1 0.2 0.5   1   2   5    10   20  50 100];
%   m = [0   0.3 0.3 0.3 0.3 0.35 0.35 0.35 0.5 0.5];
%   P.aunstruc(w,m)
%
%   %% Send to RCT
%   [RCT] = qplant2uss(P);
%   %% Send back
%   [Phat] = uss2qplant(RCT);
%
% Other m-files required: umat1x1tosyms.m, umat2syms.m, uss2syms.m, uss2syms.m
% Toolboxes required: Robust Control Toolbox, Symbolic Math Toolbox, openQsyn
%
% See also: qplant2uss
%
% Author: Benjamin Taub
% Last revision: 03-June-2020

%------------- BEGIN CODE --------------
%% Get symbolic numerator and denominator from uss
[NUM__, DEN__, ParProps__] = uss2symTF(SS__);

%% Create qpars for each parameter
for n__=1:numel(ParProps__)
    str__ = ParProps__{n__}{1}+"=qpar('"+ParProps__{n__}{1}+"',"+num2str(ParProps__{n__}{3})+","+num2str(ParProps__{n__}{2}(1))+","+num2str(ParProps__{n__}{2}(2))+",3);";
    eval(str__);
end

%% Create qpolys
num__ = eval(char(NUM__));
den__ = eval(char(DEN__));

%% Create the qplant
qp__ = qplant(num__,den__);

end


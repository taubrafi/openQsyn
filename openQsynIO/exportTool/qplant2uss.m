function [SS] = qplant2uss(qp)
%qplant2uss - Converts a qplant from openQsyn to a uss in Robust Control Toolbox
%Does not currently support uncertain number of integrators.
%Supports unstructured uncertainty by 1st order zero-pole approximations.
%
% Syntax:  [SS] = qplant2uss(qp)
%
% Inputs:
%    qp - The qplant to convert
%
% Outputs:
%    SS - The output uss
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
% Toolboxes required: Robust Control Toolbox, Symbolic Math Toolbox, openQsyn
%
% See also: uss2qplant
%
% Author: Benjamin Taub
% Last revision: 03-June-2020

%------------- BEGIN CODE --------------
%% Check for unsupported features
assert(isempty(qp.uncint), "qplant2uss does not support uncertain number of integrators at this time");

%% Create the new pars
inpars = qp.pars;
for i = 1:numel(inpars)
    % Get the properties of each param
    inpar = inpars(i);
    name = inpar.name;
    lbnd = inpar.lower; %#ok<NASGU>
    ubnd = inpar.upper; %#ok<NASGU>
    nom = inpar.nominal; %#ok<NASGU>
    names{i} = name; %#ok<AGROW,NASGU>
    
    % Create a ureal type for each param
    eval([ name ' = ureal(name,nom,''Range'', [lbnd,ubnd]);'])
end

%% Decompose the numerator
if ~isnumeric(qp.num)
    % The vector isn't entirely numeric
    % It's either a single qpar or a vector
    if isa(qp.num, 'qpar')
        % The vector is only a single qpar, so just return it.
        num = qp.num.name;
    else
        % The vector has more than one element, we have to run through
        % them and define a vector of expressions.
        N = numel(qp.num.a);
        expr = '';
        for n = 1:N
            if isnumeric(qp.num.a{n})
                % If this entry of the vector is numeric, just convert to a
                % string.
                expr = [expr,'(', num2str(qp.num.a{n}), ') ']; %#ok<AGROW>
            else
                if isa(qp.num.a{n},'qexpression')
                    % If the entry is a qepression we convert it
                    expr = [expr,'(', qp.num.a{n}.expression, ') ']; %#ok<AGROW>
                else
                    % Otherwise the entry is a qpar we convert it
                    expr = [expr,'(', qp.num.a{n}.name, ') ']; %#ok<AGROW>
                end
            end
        end
        expr = expr(1:end-1);
        num = expr;
    end
    % Create the expression
    num = eval(['[', num, ']']);
else
    % The entire vector is numeric so just return it.
    num = qp.num;
end

%% Decompose the denominator
if ~isnumeric(qp.den)
    % The vector isn't entirely numeric
    % It's either a single qpar or a vector
    if isa(qp.den, 'qpar')
        % The vector is only a single qpar, so just return it.
        den = qp.den.name;
    else
        % The vector has more than one element, we have to run through
        % them and define a vector of expressions.
        N = numel(qp.den.a);
        expr = '';
        for n = 1:N
            if isnumeric(qp.den.a{n})
                % If this entry of the vector is numeric, just convert to a
                % string.
                expr = [expr,'(', num2str(qp.den.a{n}), ') ']; %#ok<AGROW>
            else
                if isa(qp.den.a{n},'qexpression')
                    % If the entry is a qepression we convert it
                    expr = [expr,'(', qp.den.a{n}.expression, ') ']; %#ok<AGROW>
                else
                    % Otherwise the entry is a qpar we convert it
                    expr = [expr,'(', qp.den.a{n}.name, ') ']; %#ok<AGROW>
                end
            end
        end
        expr = expr(1:end-1);
        den = expr;
    end
    % Create the expression
    den = eval(['[', den, ']']);
else
    % The entire vector is numeric so just return it.
    den = qp.den;
end

%% Build the new TF
SS = tf(num,den);

%% Add unstructured uncertainty
if ~isempty(qp.unstruct)
    % Extract the freq and magnitude vectors
    w = qp.unstruct(:,1);
    m = qp.unstruct(:,2);
    
    if numel(m) > 1
        % If there is more than one element, the result is frequency
        % dependant. We need to define first order zero-pole pairs to
        % create a gain transfer function.
        % We define midpoint vectors using geometric mean.
        midw = sqrt(w(2:end).*w(1:end-1));
        midm = sqrt(m(2:end).*m(1:end-1));
        dm = diff(m);
        
        % The first entry may start from zero so we use the arithmetic mean.
        W = makePZgain(m(1), 0.5*[w(1)+w(2), m(1)+m(2)], m(2));
        
        % For the rest of the entries the geometric mean is more useful.
        % The gain for these goes from 1 to m(n+1)/m(n), since we already
        % have gain added by the previous pole-zero pairs.
        for n = 2:numel(w)-1
            if dm(n)~=0
                W = W*makePZgain(1,[midw(n),(midm(n)/m(n))],(m(n+1)/m(n)));
            end
        end
    else
        % If there is only one element, then it's just a constant gain
        % bound.
        W = m(1);
    end
    % Define an uncertain bounded LTI dynamic's element with 1 input, 1
    % output and a gain of 1 (default). Multiply this by the frequency
    % dependant gain bound.
    M = W*ultidyn('M',[1 1]);
    
    % Add this uncertainty to the tranfer function previously created.
    SS = SS*(1+M);
end

end


function [Arep__, Propmat] = umat2syms(A__)

%% Check the result isn't obvious
% If the matrix is purely numeric then nothing needs to be done.
% Just return the matrix itself
if isnumeric(A__)
    Arep__ = A__;
    Propmat = [];
    return;
end

%% Decompose to LFT
[M__,D__,B__,N__] = lftdata(A__); %#ok<ASGLU>

%% Find number of params
Npars__ = numel(N__);

%% Define new params
% Define the start of the Delta vector
defDelta__ = "[";
for i__ = 1:Npars__
    % Get the param name
    temp__ = N__{i__};
    parameterNames__{i__} = temp__.Name(1:end-10); %#ok<AGROW>
    
    % Define a symbolic to represent it
    syms(parameterNames__(i__)+"_");
    
    % Add the name to the Delta vector
    defDelta__ = defDelta__ + parameterNames__(i__) + "_" + ' ';
    
    % Add the param to an array of param properties, name, range, nominal
    Propmat{i__} = {parameterNames__{i__}, eval("D__.Uncertainty."+parameterNames__{i__}+".Range"), eval("D__.Uncertainty."+parameterNames__{i__}+".NominalValue")}; %#ok<AGROW>
end
% End of Delta vector
defDelta__ = defDelta__ + "]";

%% Define the delta matrix
Delta__ = diag(eval(defDelta__));

%% Decompose M into blocks
M11 = M__(1:Npars__,1:Npars__);
M12 = M__(1:Npars__,(Npars__+1):end);
M21 = M__((Npars__+1):end,1:Npars__);
M22 = M__((Npars__+1):end,(Npars__+1):end);

%% Recreate the symbolic version of the expression
expr__ = M22+M21*(Delta__/(eye(Npars__)-M11*Delta__))*M12;

%% Sub in the non-normalized versions
% The params come normalized, range = [-1, 1], nominal 0. So we need to
% convert this back to the range and nominal we want.
for i__ = 1:Npars__
    % Get the left, right and nominal values
    L__ = Propmat{i__}{2}(1);
    R__ = Propmat{i__}{2}(2);
    N__ = Propmat{i__}{3};
    
    % Create a non-normalized symbolic version
    pnchar__ = Propmat{i__}{1};
    syms(pnchar__);
    
    % De-norm it
    unnormed__ =  ((L__ - R__)*(N__ - eval(pnchar__)))/(L__*eval(pnchar__) - 2*N__*eval(pnchar__) + R__*eval(pnchar__) + L__*N__ - 2*L__*R__ + N__*R__);
    
    % Sub into and simplify the new expression
    expr__ = subs(expr__, parameterNames__{i__}+"_", unnormed__);
    expr__ = simplify(expr__, 10);
end

%% Return the resulting expression (may be a matrix)
Arep__ = expr__;

end


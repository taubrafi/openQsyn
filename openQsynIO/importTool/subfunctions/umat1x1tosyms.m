function [expr] = umat1x1tosyms(A)

if isnumeric(A)
    expr = A;
    return;
end
[M,D,B,N] = lftdata(A);

%% Find number of params
Npars = numel(N);

%% Define params

defDelta = "[";
for i = 1:Npars
    temp = N{i};
    parameterNames{i} = temp.Name(1:end-10);
    syms([parameterNames(i)+"_"]);
    defDelta = defDelta + parameterNames(i) + "_" + ' ';
    Propmat{i} = {parameterNames{i}, eval("D.Uncertainty."+parameterNames{i}+".Range"), eval("D.Uncertainty."+parameterNames{i}+".NominalValue")};
end
defDelta = defDelta + "]";
Delta = diag(eval(defDelta));

M11 = M(1:end-1,1:end-1);
M12 = M(1:end-1,end);
M21 = M(end,1:end-1);
M22 = M(end,end);
expr = M22+M21*(Delta/(eye(Npars)-M11*Delta))*M12;

for i = 1:Npars
    m = Propmat{i}{2}(1);
    M = Propmat{i}{2}(2);
    pnchar = Propmat{i}{1};
    syms(pnchar);
    expr = subs(expr, parameterNames{i}+"_", -1+2*(eval(pnchar)-m)/(M-m));
    expr = simplify(expr,10);
end

end


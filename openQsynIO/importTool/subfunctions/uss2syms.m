function [A,B,C,D, Propmat] = uss2syms(SSin)

%% Extract each SS component as a symbolic matrix
% and return the properties of the params to define.
[A, PropmatA] = umat2syms(SSin.A);
[B, PropmatB] = umat2syms(SSin.B);
[C, PropmatC] = umat2syms(SSin.C);
[D, PropmatD] = umat2syms(SSin.D);

%% Put together all the parameter properties
Propmat = [PropmatA PropmatB PropmatC PropmatD];

end


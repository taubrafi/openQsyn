function [NUM, DEN, ParProps] = uss2symTF(SSin)

%% Create the laplace variable
syms s;

%% Get the state space representation
if isa(SSin,'tf')
    % For a certain state space model
    [A,B,C,D] = tf2ss(SSin.Numerator{:}, SSin.Denominator{:});
    % There are no uncertain params
    ParProps = [];
else
    % For an uncertain state space model
    [A,B,C,D, ParProps] = uss2syms(SSin);
end

%% Get the TF from the SS
n = numel(B);
H = C/(s*eye(n)-A)*B+D;

%% Get the num and denom coeffs
[NUM, DEN] = numden(H);
NUM = coeffs(NUM,s,'All');
DEN = coeffs(DEN,s,'All');

end


%% Initialize
clc;
clear;
close all;

%% Plant from openQsyn
k=qpar('k',2,2,5,8);
a=qpar('a',3,1,3,8);
z=qpar('z',0.6,0.3,0.6,8);
wn=qpar('wn',4,4,8,8);

num = [k*wn*wn k*wn*wn*a];
den = [1 2*z*wn wn*wn];
P = qplant(num,den);

%% Uncertain number of poles ar origin (will give error)
% P.auncint([2 4]);

%% Unstructured uncertainty
w = [0.1 0.2 0.5   1   2   5    10   20  50 100];
m = [0   0.3 0.3 0.3 0.3 0.35 0.35 0.35 0.5 0.5];
P.aunstruc(w,m)

%% Send to RCT
[RCT] = qplant2uss(P);

%% Send back
[Phat] = uss2qplant(RCT);



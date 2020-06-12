%% Unstructured transfer demonstration
% The purpose of this demo is to show how unstructured uncertainty is
% handled by the export tool. The gain over frequency is converted to a 1st
% order zero-pole approximation. This results in a structure that can be
% represented as a state space which is how Robust Control Toolbox
% represents the systems.

%% Initialize
clc;
clear;
close all;

%% Unstructured uncertainty
w = [0.1 0.2 0.5   1   2   5    10   20  50 100];
m = [0   0.3 0.3 0.3 0.3 0.35 0.35 0.35 0.5 0.5];

%% Create 1st order zeros-pole approximation
midw = sqrt(w(2:end).*w(1:end-1));
midm = sqrt(m(2:end).*m(1:end-1));
dm = diff(m);
W = makePZgain(m(1), 0.5*[w(1)+w(2), m(1)+m(2)], m(2));
for n = 2:numel(w)-1
    if dm(n)~=0
        W = W*makePZgain(1,[midw(n),(midm(n)/m(n))],(m(n+1)/m(n)));
    end
end

%% Plot the result and the input
figure(1);
clf;
bodemag(W); hold on;
plot(w, db(m),'g.-');
legend('output','desired');
grid on;


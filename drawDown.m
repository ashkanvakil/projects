function [DD, maxDD] = drawDown(X)
T = length(X);
lastPeak = zeros(T,1);
DD = zeros(T,1);
lastPeak(1,1) = X(1,1);
for t = 2:T
    lastPeak(t,1) = max(lastPeak(t-1,1), X(t,1));
    if X(t,1) == lastPeak(t,1)
        DD(t,1) = 0;
    else
        DD(t,1) = X(t,1) - lastPeak(t,1);
    end
end
maxDD = -max(-DD);
end
clc
clear

Connect = yahoo;
s = {'SPY', '^VIX', 'XIV', 'VXX'};
d1 = '1/1/2000';
d2 = now;
X = builduniverse(Connect, s, d1, d2, 'd');
r = [X(:, 1) [nan(1, length(s)); diff(X(:, 2:end))]];
date = r(:, 1);

%%
data = nan(size(r));
data(:, 1) = date;
for i = 1:length(s)
    tmp = flipud(fetch(Connect, s{i}, 'Adj Close', d1, d2));
    idx = ismember(data(:, 1), tmp(:, 1));
    data(idx, i+1) = tmp(:, 2);
end

%%
SPYVol_10dTimes100 = nan(length(r), 1);
w = 10;
SPYVol_10dTimes100(w:end, 1) = sqrt(250) * 100 * rollingStdev(r(:, 2), 10);
signal.s = sign(data(:, 3) - SPYVol_10dTimes100);
signal.date = date;

%%
for t = 1:length(r)
    if signal.s(t) == 1
        stratReturn(t) = r(t, 3);
    elseif signal.s(t) == -1
        stratReturn(t) = r(t, 4);
    else
        stratReturn(t) = nan;
    end
end
stratReturn = stratReturn';
idx = find(~isnan(r(:, 4)), 1, 'first');
stratReturn = stratReturn(idx:end);
stratReturnCum = cumprod(1+stratReturn);
stratDate = data(idx:end, 1);

%%
SR = nanmean(stratReturn) / nanstd(stratReturn) * sqrt(250);

[DD, maxDD] = drawDown(stratReturnCum);

%%
plot(stratDate, stratReturnCum)
hold on
plot(stratDate, cumprod(1 + r(idx:end, 3)), 'r')
datetick('x','mmm-yy')
legend('Strategy', 'XIV')
axis tight

%%
plot(stratDate, 100 * DD, 'r')
datetick('x','mmm-yy')
axis tight

%%
plot(date, SPYVol_10dTimes100)
hold on
plot(date, data(:, 3), 'r')
datetick('x','mmm-yy')
axis tight
legend('SPY Historical Vol', 'VIX')

%%
plot(signal.date, signal.s, 'color',  [0 0.7 0.2])
datetick('x','mmm-yy')
axis([signal.date(1) signal.date(end) -1.2 1.2])



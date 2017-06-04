clc
clear

Connect = yahoo;
s = {'^VIX', '^VXV', 'ZIV'};
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
for t = 1:length(r)
    if data(t, 2) < 0.9 * data(t, 3)
        signal.s(t) = 1;
    else
        signal.s(t) = 0;
    end
end
signal.date = date;

stratReturn = signal.s' .* r(:, 4);
idx = find(~isnan(r(:, 4)), 1, 'first');
stratReturn = stratReturn(idx:end);
stratReturnCum = cumprod(1+stratReturn);
stratDate = signal.date(idx:end, 1);

SR = nanmean(stratReturn) / nanstd(stratReturn) * sqrt(250);
[DD, maxDD] = drawDown(stratReturnCum);

%%
plot(stratDate, stratReturnCum)
datetick('x','mmm-yy')
axis tight

%%
plot(stratDate, 100 * DD, 'r')
datetick('x','mmm-yy')
axis tight

%%
plot(signal.date, signal.s, 'color',  [0 0.7 0.2])
datetick('x','mmm-yy')
axis([signal.date(1) signal.date(end) -0.2 1.2])

%%
noSwitch = sum(abs(diff(signal.s))) * 250 / length(signal.s);
function c = rollingCorr(x1, x2, w)
y = zscore(x2);
n = size(y, 1);

if (n < w)
    c = NaN(n, 1);
else
    x = zscore(x1);
    x2 = x .^ 2;
    y2 = y .^ 2;
    xy = x .* y;
    A = 1;
    B = ones(1, w);
    stdx = sqrt((filter(B, A, x2) - (filter(B, A, x) .^ 2) * (1/w)) / (w-1));
    stdy = sqrt((filter(B, A, y2) - (filter(B, A, y) .^ 2) * (1/w)) / (w-1));
    c = (filter(B, A, xy) - filter(B, A, x) .* filter(B, A, y) / w) ./ ((w-1) * stdx .* stdy);
    c(1:(w-1)) = [];
end
end
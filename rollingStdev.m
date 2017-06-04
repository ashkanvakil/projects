function SD = rollingStdev(x, w)
convsig = ones(1, w);
for i = 1:size(x, 2)
    y = x(:, i);
    SD(:, i) = sqrt((conv(y .^ 2, convsig, 'valid') -...
        (conv(y, convsig, 'valid').^2) / w) / (w-1));
end
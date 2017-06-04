%% import data
clc
clear
myFolder = 'C:\Users\Ashkan\Google Drive\My Files\Finance & Econ\Personal Portfolio\Data\';
myFile = 'FX_FW_Spot.xlsm';
[~, ~, raw] = xlsread([myFolder myFile], 'FX_FW_Spot');
rawNoHeader = raw(29:end, :);
header = raw(2, 2:2:end);
header = cellfun(@(x) x(1:3),header(cellfun('length',header) > 1),'un',0);
num = cell2mat(rawNoHeader(:, 2:end));

myFile = 'FX_Data.xlsx';
[~, ~, raw2] = xlsread([myFolder myFile], '$_Carry_ETFs');

%%
idx_first = find(~isnan(sum(num, 2)), 1,'first');
idx_last = find(~isnan(sum(num, 2)), 1, 'last');
idx = idx_first:idx_last;
num = num(idx, :);

%%
indexCurrency = [2:6 8];
date = datenum(rawNoHeader(idx,1), 'mm/dd/yyyy');
FXSpot = 1 ./ num(:,2:2:end);
FXSpot = FXSpot(:, indexCurrency);
spotRet = FXSpot(2:end, :) ./ FXSpot(1:end-1, :) - 1;
FXFw = 1 ./ num(:,1:2:end);
FXFw = FXFw(:, indexCurrency);
fwRet = (FXSpot(2:end, :) - FXFw(1:end-1, :)) ./ FXSpot(1:end-1, :);
date = date(2:end,1);
header = header(indexCurrency);

%% carry
[T, noFX] = size(FXSpot);
zCT = FXFw ./ FXSpot - 1;
rankCT = zeros(T, noFX);
for t = 1:T
    [~,~,tmp] = unique(zCT(t, :));
    rankCT(t, :) = noFX - tmp' + 1;
end

% weights
w = rankCT - repmat(mean(rankCT, 2), 1, noFX);
w = w ./ repmat(sum(double(w>0) .* w, 2), 1, noFX);
w = w(2:end, :);

wLO = w;
wLO(wLO < 0) = 0;

%
carryLSRet = sum(w .* fwRet, 2);
carryLSCumRet = cumprod(1 + carryLSRet);

carryLORet = sum(wLO .* fwRet, 2);
carryLOCumRet = cumprod(1 + carryLORet);

% IR
IR_LS = mean(carryLSRet) / std(carryLSRet);
IR_LO = mean(carryLORet) / std(carryLORet);

% Drawdown
[DD_LS, maxDD_LS] = drawDown(carryLSCumRet);
[DD_LO, maxDD_LO] = drawDown(carryLOCumRet);

%% FX carry strategy summary
notional = 10000;
figure('Color',[0.86 0.86 0.86]);
subplot(2,2,1)
plot(date, notional*carryLSCumRet, 'linewidth', 2)
title('Long-Short')
text(date(20), 1.7*notional, sprintf('IR = %0.2f', IR_LS),...
    'fontsize', 8, 'fontweight', 'bold', 'BackgroundColor', 'y', 'EdgeColor', 'k')
ylabel(sprintf('Growth of $%0.0f', notional))
datetick('x','mmm-yy')
axis tight

subplot(2,2,3)
plot(date, notional*DD_LS, 'r', 'linewidth', 2)
ylabel('Drawdown')
datetick('x','mmm-yy')
axis tight
text(date(20),0.8*notional*maxDD_LS, sprintf('Max DD = $%0.0f', -notional*maxDD_LS),...
    'fontsize', 8, 'fontweight', 'bold', 'BackgroundColor', 'y', 'EdgeColor', 'k')

subplot(2,2,2)
plot(date, notional*carryLOCumRet, 'linewidth', 2)
title('Long-Only')
text(date(20), 1.5*notional, sprintf('IR = %0.2f', IR_LO),...
    'fontsize', 8, 'fontweight', 'bold', 'BackgroundColor', 'y', 'EdgeColor', 'k')
ylabel(sprintf('Growth of $%0.0f', notional))
datetick('x','mmm-yy')
axis tight

subplot(2,2,4)
plot(date, notional*DD_LO, 'r', 'linewidth', 2)
ylabel('Drawdown')
datetick('x','mmm-yy')
axis tight
text(date(20), 0.8*notional*maxDD_LO, sprintf('Max DD = $%0.0f', -notional*maxDD_LO),...
    'fontsize', 8, 'fontweight', 'bold', 'BackgroundColor', 'y', 'EdgeColor', 'k')

%% $ Carry Trade Signal
UUP = cell2mat(raw2(2:end, 2));
UDN = cell2mat(raw2(2:end, 3));
dateDollarC = date(100:end,1);
AFD = mean(log(FXFw(101:end,:) ./ FXSpot(101:end,:)), 2);
[T_UUP, n] = size(UUP);
DollarCarry = zeros(T_UUP, n);
DollarCarry(1) = UUP(1);
for t = 1:T_UUP-1
    if AFD(t) > 0
        DollarCarry(t+1) = UDN(t+1);
    elseif AFD(t) < 0
        DollarCarry(t+1) = UUP(t+1);
    end
end

DollarCarryCum = cumprod(1 + DollarCarry);
UUPCum = cumprod(1 + UUP);
UDNCum = cumprod(1 + UDN);

% IR
IR_DC = mean(DollarCarry) / std(DollarCarry);

% Drawdown
[DD_DC, maxDD_DC] = drawDown(DollarCarryCum);

%%
figure()
plot(dateDollarC, 1200*AFD)
grid on
axis tight
datetick('x','mmm-yy')
notional = 10000;
figure('Color',[0.86 0.86 0.86]);
subplot(2,1,1)
plot(dateDollarC, notional*DollarCarryCum, 'linewidth', 2)
hold on
plot(dateDollarC, notional*UDNCum, 'k', 'linewidth', 2)
hold on
plot(dateDollarC, notional*UUPCum, 'g', 'linewidth', 2)
legend('Dollar Carry', 'UDN', 'UUP', 'location', 'best')
text(dateDollarC(20), 1.1*notional, sprintf('IR = %0.2f', IR_DC),...
    'fontsize', 8, 'fontweight', 'bold', 'BackgroundColor', 'y', 'EdgeColor', 'k')
ylabel(sprintf('Growth of $%0.0f', notional))
datetick('x','mmm-yy')
axis tight

subplot(2,1,2)
plot(dateDollarC, notional*DD_DC, 'r', 'linewidth', 2)
ylabel('Drawdown')
datetick('x','mmm-yy')
axis tight
text(dateDollarC(20),0.8*notional*maxDD_DC, sprintf('Max DD = $%0.0f', -notional*maxDD_DC),...
    'fontsize', 8, 'fontweight', 'bold', 'BackgroundColor', 'y', 'EdgeColor', 'k')
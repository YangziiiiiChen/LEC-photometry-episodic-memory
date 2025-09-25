function [Y_dF_all, zall, ErrorWidth] = Event_Locked_Activity(TargetTS, PhotometryData, Type, scat, fname_TDT, ifplot)

PhotoTS = PhotometryData.timestamp;

GFP_Raw = []; GCAMP_Raw = [];
for i = 1:length(TargetTS)
    [~, st] = min(abs(PhotoTS - (TargetTS(i)-1))); % +/- 1 sec
    [~, ed] = min(abs(PhotoTS - (TargetTS(i)+1)));

    gfp = PhotometryData.GFP(st:ed);
    gcamp = PhotometryData.GCAMP(st:ed);

    if length(gfp) > 2000
        GFP_Raw(i,:) = gfp(1:2000);
        GCAMP_Raw(i,:) = gcamp(1:2000);
    else
        i
    end
end

% downsample 10x and average 405 signal
N = 10;
F405 = zeros(size(GFP_Raw(:,1:N:end-N+1)));
for ii = 1:size(GFP_Raw,1)
    F405(ii,:) = arrayfun(@(i) mean(GFP_Raw(ii,i:i+N-1)),1:N:length(GFP_Raw)-N+1);
end
minLength1 = size(F405,2);

% Create mean signal, standard error of signal, and DC offset of 405 signal
meanSignal1 = mean(F405);
baselineSignal1 = mean(meanSignal1);

% downsample 10x and average 465 signal
F465 = zeros(size(GCAMP_Raw(:,1:N:end-N+1)));
for ii = 1:size(GCAMP_Raw,1)
    F465(ii,:) = arrayfun(@(i) mean(GCAMP_Raw(ii,i:i+N-1)),1:N:length(GCAMP_Raw)-N+1);
end
minLength2 = size(F465,2);

% Create mean signal, standard error of signal, and DC offset of 465 signal
meanSignal2 = mean(F465);
stdSignal2 = std(double(F465))/sqrt(size(F465,1));
baselineSignal2 = mean(meanSignal2);

% Adjust the amplitude of both signals
AdjustR = baselineSignal2 / baselineSignal1; % 465/405
meanSignal1 = meanSignal1*AdjustR;
F405 = F405 * AdjustR;
stdSignal1 = std(double(F405))/sqrt(size(F405,1));

% Subtract DC offset to get signals on top of one another
dcSignal1 = mean(meanSignal1);
meanSignal1 = meanSignal1 - dcSignal1;
dcSignal2 = mean(meanSignal2);
meanSignal2 = meanSignal2 - dcSignal2;

% Plot the 405 and 465 average signals
ID = 0:1:(length(meanSignal1)-1);
ID = (ID*10-1000)/1000; % converting to msec

if ifplot
    figure;
    set(gcf, 'Position',[100, 100, 350, 500]);
    subplot(3,1,1)
    plot(ID, meanSignal1, 'color',[0.4660, 0.6740, 0.1880], 'LineWidth', 3); hold on;
    plot(ID, meanSignal2, 'color',[0.8500, 0.3250, 0.0980], 'LineWidth', 3);
    title(Type);
    % Make a legend
    legend('405 nm','465 nm','AutoUpdate', 'off');
    % % Create the standard error bands for the 405 signal
    XX = [ID, fliplr(ID)];
    YY = [meanSignal1 + stdSignal1, fliplr(meanSignal1 - stdSignal1)];
    % % Plot filled standard error bands.
    h = fill(XX, YY, 'g');
    set(h, 'facealpha',.25,'edgecolor','none')
    % % Repeat for 465
    XX = [ID, fliplr(ID)];
    YY = [meanSignal2 + stdSignal2, fliplr(meanSignal2 - stdSignal2)];
    h = fill(XX, YY, 'r');
    set(h, 'facealpha',.25,'edgecolor','none')
    V=axis;
    line([0 0], [V(3), V(4)], 'Color', [.7 .7 .7], 'LineWidth', 2);
    % Finish up the plot
    axis tight
    xlabel('Time, s','FontSize',12)
    ylabel('mV', 'FontSize', 12)
end
% Heat Map based on z score of 405 fit subtracted 465

% Fitting 405 channel onto 465 channel to detrend signal bleaching
% Scale and fit data
% Algorithm sourced from Tom Davidson's Github:
% https://github.com/tjd2002/tjd-shared-code/blob/master/matlab/photometry/FP_normalize.m

% bls is changed to using all data of 405 and 465 
bls = polyfit(F405(1:end), F465(1:end), 1);
Y_fit_all = bls(1) .* F405 + bls(2);
Y_dF_all = F465 - Y_fit_all;

% Coverting raw dF/F to z-scores in each trial
zall = zeros(size(Y_dF_all));
for i = 1:size(Y_dF_all,1)
    ind = 1:size(Y_dF_all,2); 
    med = median(Y_dF_all(i,ind));              
    mad_val = median(abs(Y_dF_all(i,ind)-med)); 
    zall(i,:) = 0.6745 * (Y_dF_all(i,:) - med) / mad_val;
end

% Standard error of the z-score
zerror = std(zall,0,1)/sqrt(size(zall,1));ff

if ifplot
    % Plot heat map
    subplot(3,1,2)
    imagesc(ID, 1, zall, [-3 3]);
    colormap('redblue'); % c1 = colorbar;
    ylabel('Trials', 'FontSize', 12);
    % Fill band values for second subplot. Doing here to scale onset bar
    % correctly
    XX = [ID, fliplr(ID)];
    YY = [mean(zall)-zerror, fliplr(mean(zall)+zerror)];
    subplot(3,1,3)
    plot(ID, mean(zall), 'color',[0.8500, 0.3250, 0.0980], 'LineWidth', 3); hold on;
    line([0 0], [min(YY), max(YY)], 'Color', [.7 .7 .7], 'LineWidth', 2)
    h = fill(XX, YY, 'r');
    set(h, 'facealpha',.25,'edgecolor','none')
    % Finish up the plot
    axis tight
    xlabel('Time, s','FontSize',12)
    ylabel('Z-score', 'FontSize', 12)
end

ErrorWidth = stdSignal2(1);

if scat == 1 && ifplot == 1
    figure; scatter(F405(1:end), F465(1:end), 'filled');
    xlabel('GFP'); ylabel('GCamp');
    title(fname_TDT)
end

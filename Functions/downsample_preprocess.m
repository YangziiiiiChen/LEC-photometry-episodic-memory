function Signal_corrected = downsample_preprocess(data, newLength)
    if nargin < 2
        newLength = 400;
    end

    [nTrial, nTime] = size(data);
    x_old = linspace(1, nTime, nTime);
    x_new = linspace(1, nTime, newLength);

    data_ds = zeros(nTrial, newLength);
    for i = 1:nTrial
        data_ds(i,:) = interp1(x_old, data(i,:), x_new, 'linear');
    end
    meanSignal = mean(data_ds, 1, 'omitnan');
    dcSignal = mean(meanSignal, 'omitnan');  
    Signal_corrected = meanSignal - dcSignal;
end
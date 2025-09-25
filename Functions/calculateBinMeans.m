function result = calculateBinMeans(data)
    if size(data, 2) ~= 2
        result = [];
        return;
    end
    values = data(:, 2);
    bins = data(:, 1);
    all_bins = (1:24)';
    bin_means = arrayfun(@(bin) mean(values(bins == bin), 'omitnan'), all_bins);
    bin_means(cellfun(@(x) isempty(values(bins == x)), num2cell(all_bins))) = NaN;
    result = [all_bins, bin_means];
end

function bin = spatial_bins(coords, num_bins)
bin_edges = linspace(min(coords), max(coords), num_bins + 1);
[~, ~, bin] = histcounts(coords, bin_edges);
end
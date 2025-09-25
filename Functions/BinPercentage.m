function percentages = BinPercentage(data)
    unique_vals = unique(data); 

    counts = histc(data, unique(data));
    percentages = counts / sum(counts);
end

function A_max = max_by_groups(A, group_size)
    num_groups = size(A, 2) / group_size;
    A_max = arrayfun(@(i) nanmedian(A(:, (i-1)*group_size + 1 : i*group_size), 2), ...
        1:num_groups, 'UniformOutput', false);
    A_max = horzcat(A_max{:});
end
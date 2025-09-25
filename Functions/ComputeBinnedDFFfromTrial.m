function result = ComputeBinnedDFFfromTrial(DLC, type, dFF, FPtime) % input DLC consists of converted_X, converted_Y, timestamp
result = [];

trial_FPdat = [dFF' FPtime'];
coord_indices = zeros(1, length(DLC));
for j = 1:length(DLC)
    [~, coord_indices(j)] = min(abs(DLC(j,3) - trial_FPdat(:,2)));
end

indices_diff = diff(coord_indices)-1;
dFF_index_range = [coord_indices(1) coord_indices(end)];
start_idx = 1;
X = []; Y = [];
for j = 1:length(DLC)-1
    new_coords_X = linspace(DLC(j,1), DLC(j+1,1), indices_diff(j)+2);
    new_coords_Y = linspace(DLC(j,2), DLC(j+1,2), indices_diff(j)+2);
    new_coords_X = new_coords_X(1:end-1); new_coords_Y = new_coords_Y(1:end-1);
    X = [X new_coords_X]; Y = [Y new_coords_Y];
end
X = [X DLC(j+1,1)]; Y = [Y DLC(j+1,2)];
if strcmp(type,'12') || strcmp(type,'21') || strcmp(type,'34') || strcmp(type,'43')
    single_trial_dat = [spatial_bins(X, 24)' trial_FPdat(dFF_index_range(1):dFF_index_range(2), 1)];
    single_trial_BinMean = calculateBinMeans(single_trial_dat);
    result = [result; single_trial_BinMean(:,2)'];
elseif strcmp(type,'23') || strcmp(type,'32') || strcmp(type,'41') || strcmp(type,'14')
    single_trial_dat = [spatial_bins(Y, 24)' trial_FPdat(dFF_index_range(1):dFF_index_range(2), 1)];
    single_trial_BinMean = calculateBinMeans(single_trial_dat);
    result = [result; single_trial_BinMean(:,2)'];
end




end
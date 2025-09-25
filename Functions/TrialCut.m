function result = TrialCut(dat)

corner_idx = find(dat(:,9) ~= 0);
dat_corner = dat(corner_idx, :);
cut_idx = find(diff(dat_corner(:,4)) > 0.4);

start_idx = 1;
dat_no_corner = dat(dat(:,9) == 0, :);
DLC_divided = {};
trial_type = {};

valid_idx = 1;
for i = 1:numel(cut_idx)
    end_idx = cut_idx(i);
    start_time = dat_corner(start_idx, 4);
    end_time = dat_corner(end_idx+1, 4);
    trial_type_tmp = num2str(dat_corner(start_idx, 9)*10 + dat_corner(end_idx+1, 9));
    trial_rows = dat_no_corner(:,4) >= start_time & dat_no_corner(:,4) <= end_time;
    trial_data = dat_no_corner(trial_rows, :);
    
    if size(trial_data, 1) >= 20
        DLC_divided{valid_idx} = trial_data;
        trial_type{valid_idx} = trial_type_tmp;
        valid_idx = valid_idx + 1;
    end

    start_idx = end_idx + 1;
end

result = struct( ...
    'DLC_dat', DLC_divided, ...
    'trialtype', trial_type ...
);


end
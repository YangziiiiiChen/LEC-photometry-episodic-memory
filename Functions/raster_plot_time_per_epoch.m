function figure_handles = raster_plot_time_per_epoch(design_mat_name, data_path, type)

Dates = readtable(design_mat_name, 'TextType', 'string', 'ReadVariableNames', true); cue_dates = Dates{:, 2:end};
Design = readtable(design_mat_name, 'Sheet','Ifvalid', 'ReadVariableNames', true); design_mat = Design{:, 2:end};
valid_animal_index = any(design_mat, 2);
Animals = cellstr(Dates{valid_animal_index, 1}');
FolderPath = fullfile(data_path, 'Output\Processed Data');
FileList = dir(FolderPath);
n = 256;
red = [linspace(0,1,n/2) ones(1,n/2)]';
green = [linspace(0,1,n/2) linspace(1,0,n/2)]';
blue = [ones(1,n/2) linspace(1,0,n/2)]';
redblue = [red green blue];
clims = [-2 2];
defaultPos = get(0, 'DefaultFigurePosition'); 
newWidth = defaultPos(3)/3;
newHeight = defaultPos(4);
mapping_TypeToIndex = containers.Map({'Photometry_hit', 'Photometry_miss', 'Photometry_correct_rejection', 'Photometry_false_alarm'}, [1 2 3 4]);
animal_figs = gobjects(1, numel(Animals)); 

sliding_window_size = 20;

for animal_index = 1:numel(Animals)
    animal = Animals{animal_index};
    animal_figs(animal_index) = figure('Name', animal, ...
        'Position', [defaultPos(1), defaultPos(2), newWidth, newHeight]);
    
    for epoch = 1:2
        num_days = numel(cue_dates(animal_index,:));
        
        for i = 1:num_days
            figure(animal_figs(animal_index)); 
            subplot(2, num_days, num_days*(epoch-1)+i);
            filename = sprintf('%s25_%s_LEC2PFC_E%d_time.mat', cue_dates{animal_index, i}, animal, epoch);
            if ~exist(fullfile(FolderPath, filename))
                continue;
            end

            load(fullfile(FolderPath, filename));
            plot_data = eval(type);
            
            [~, sort_idx] = sort(centered_speed{mapping_TypeToIndex(type)});
            n = floor(length(sort_idx));
            if n < 2
                continue;
            end
            sort_idx = sort_idx(1:n);
            plot_data = plot_data(sort_idx, :);
            zscored_plot_data = zscore(plot_data')';
            imagesc(movmean(zscored_plot_data, 15, 2), clims); hold on; box off; axis on;
            colormap(jet);
            clim([-3 3]);
            title(sprintf('%s - Epoch %d', cue_dates{animal_index, i}, epoch), 'FontWeight', 'bold');
            yticks([1 n]);
            yticklabels({'Low', 'High'});
            xticks([100 3020 6040]);
            xticklabels({'-3', '0', '3'});
            xlabel('time (s)');
        end
    end
    
   
    figure(animal_figs(animal_index));
    sgtitle(sprintf('Animal %s', animal));
end

figure_handles = animal_figs;

end
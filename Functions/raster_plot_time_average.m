function figure_handles = raster_plot_time_average(design_mat_name, data_path, type)

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

for animal_index = 1:numel(Animals)
    animal = Animals{animal_index};
    animal_figs(animal_index) = figure('Name', animal, ...
        'Position', [defaultPos(1), defaultPos(2), newWidth, newHeight]);
    
    for epoch = 1:2
        epoch_name = ['E', num2str(epoch)];
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
            zscored_plot_data = zscore(plot_data')';
            plot_data = movmean(zscored_plot_data, 30, 2);
            shadedErrorBar(1:size(plot_data,2), mean(plot_data,1), std(plot_data,0,1)/sqrt(size(plot_data,1)), 'lineprops', '-k');
            hold on;
            title(sprintf('%s - Epoch %d', cue_dates{animal_index, i}, epoch), 'FontWeight', 'bold');
            ylim([-2 2]);
            xticks([100 3000 6020]);
            xticklabels({'-3', '0', '3'});
            xlabel('time (s)');
        end
    end
    
   
    figure(animal_figs(animal_index));
    sgtitle(sprintf('Animal %s', animal));
end

figure_handles = animal_figs;

end
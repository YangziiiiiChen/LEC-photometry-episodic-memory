function figure_handles = raster_plot_location_average(design_mat_name, data_path, type)

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
        matched_files = FileList(arrayfun(@(f) contains(f.name, animal) && contains(f.name, epoch_name) && contains(f.name, 'location'), FileList));
        num_days = numel(cue_dates(animal_index,:));
        
        for i = 1:num_days
            figure(animal_figs(animal_index)); 
            subplot(2, num_days, num_days*(epoch-1)+i);
            load(fullfile(FolderPath, matched_files(i).name));
            plot_data = eval(type);
            shadedErrorBar(1:size(plot_data,2), mean(plot_data,1), std(plot_data,0,1)/sqrt(size(plot_data,1)), 'lineprops', '-k');
            title(sprintf('Day %d - Epoch %d', i, epoch), 'FontWeight', 'bold');
            ylim([-1 1]);
            xticks([1 12.5 24]);
            xticklabels({'1', 'Center', '24'});
            xlabel('Spatial bin');
            set(gca, 'TickLength', [0 0]);
        end
    end
    
   
    figure(animal_figs(animal_index));
    sgtitle(sprintf('Animal %s', animal));
end

figure_handles = animal_figs;

end
function dFF_event_locked(design_mat, data_path, output_filename, ifplot)

Dates = readtable(design_mat, 'TextType', 'string', 'ReadVariableNames', true); cue_dates = Dates{1:end, 2:end};
Ifvalid = readtable(design_mat, 'Sheet','IfValid', 'ReadVariableNames', true); valid_mat = Ifvalid{1:end, 2:end};
Animals = cellstr(Dates{1:end, 1}');
RawPath = fullfile(data_path, 'Output\Raw Data');
ZscoreAll = cell(size(Animals, 2), size(cue_dates, 2), 2);
StdGcampAll = cell(size(Animals, 2), size(cue_dates, 2), 2);


for animal_index = 1:size(Animals, 2)
    animal = Animals{animal_index};

    for date_index = 1:size(cue_dates, 2)
        date = string(cue_dates(animal_index, date_index));
        for epoch = 1:2
            date_formatted = strcat(date, '25');
            if ismissing(animal) || ismissing(date)
                continue;
            end
            RawName = fullfile(RawPath, sprintf('%s_%s_LEC2PFC_E%d.mat', date_formatted, animal, epoch));
            if ~exist(RawName)
                continue;
            end
            [AveZscore, Std_GCAMP] = Calculate_dFoF_V2(RawName, ifplot);
            figFolder = fullfile(fullfile(data_path, 'Output\Raw Signal Figures'), [char(animal) '_' char(date)  '_' num2str(epoch)]); % 在当前工作目录下创建 Figures 文件夹
            if ~exist(figFolder, 'dir')
                mkdir(figFolder);
            end

            figs = findall(0, 'Type', 'figure');

            for i = 1:length(figs)
                figName = fullfile(figFolder, ['Figure_' num2str(i) '.png']);
                saveas(figs(i), figName);
            end

            close all;

            ZscoreAll{animal_index, date_index, epoch} = AveZscore;
            StdGcampAll{animal_index, date_index, epoch} = Std_GCAMP;
            disp(RawName);
        end
    end
end


save(fullfile(data_path, fullfile('Output', output_filename)), 'ZscoreAll', 'StdGcampAll')

end
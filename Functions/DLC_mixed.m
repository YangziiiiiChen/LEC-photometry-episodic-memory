function DLC_mixed(design_mat, data_path)

Dates = readtable(design_mat, 'TextType', 'string'); days_mat = Dates{:, 2:end};
Dates = readtable(design_mat, 'Sheet', 'Sheet2'); cue_design = Dates{2:end, 2:end};
Animals = cellstr(Dates{1:end, 1}');
num_days = size(days_mat, 2);
num_epochs = 2;
num_animals = size(Animals, 2);
bd1path = fullfile(data_path, 'DLC\CAM 1');
bd2path = fullfile(data_path, 'DLC\CAM 2');
dat_all = cell([num_days, num_epochs, num_animals]);

for animal_index = 1:num_animals
    animal = Animals{animal_index};
    for day_index = 1:num_days
        day = days_mat{animal_index, day_index};
        folderPath = fullfile(data_path, 'Pycontrol', day);

        if ismissing(day)
            continue;
        end

        cue_epoch_number = cue_design(animal_index, day_index);
        if ismissing(cue_epoch_number)
            continue;
        end
        if cue_epoch_number == 2
            TSVfname = find_tsv(folderPath, strcat(animal, '_1'));
        else
            TSVfname = find_tsv(folderPath, strcat(animal, '_0'));
        end
        rewarded = find_correct_port(TSVfname);
        unrewarded = setdiff([1 2 3 4], rewarded);


        for epoch = 1:num_epochs
            % find the rewarded indices
            % for example, if AD is rewarded then the variable 'rewarded' will be [1 4]
            
            filename_pattern_cam1 = sprintf('%s_%s_%dDLC_resnet50_CAM 1Dec1shuffle1_100000.csv', day, animal, epoch-1);
            filename_pattern_cam2 = sprintf('%s_%s_%dDLC_resnet50_CAM 2Nov29shuffle1_100000.csv', day, animal, epoch-1);
            cam1_filename = fullfile(bd1path, filename_pattern_cam1);
            cam2_filename = fullfile(bd2path, filename_pattern_cam2);

            fr_1 = 29.83; fr_2 = 29.83;
            result = match_coords(cam1_filename, cam2_filename, fr_1, fr_2);
            if ~isstruct(result)
                continue;
            end
            % result returned by function 'match_coords' such as P1 will be
            % in the format of [original coords in Path 1 (dim: nx2); speed; timestamp; mapped coords in the ideal square (dim: nx2)]
            % Therefore, the overall dim of P will be nx6, depending how
            % many frames are in that P
            dat_all{day_index, epoch, animal_index} = result.All;

        end
    end
end

savePath = fullfile(data_path, 'Output');
save(fullfile(savePath, 'mixed_DLC.mat'), 'dat_all');


end
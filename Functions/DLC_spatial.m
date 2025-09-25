function DLC_spatial(design_mat, data_path)


opts = detectImportOptions(design_mat, 'TextType','string', 'ReadVariableNames', true);
Dates = readtable(design_mat, opts); days_mat = Dates{1:end, 2:end};
Animals = cellstr(Dates{1:end, 1}');
bd1path = fullfile(data_path, 'DLC\CAM 1');
bd2path = fullfile(data_path, 'DLC\CAM 2');

num_days = size(days_mat, 2);
num_epochs = 2;
num_animals = size(Animals, 2);

dat_all = cell([num_days, num_epochs, num_animals]);

for animal_index = 1:num_animals
    for day_index = 1:num_days
        day = days_mat(animal_index, day_index);
        if ismissing(day)
            continue;
        end
        for epoch = 1:2
            animal = Animals{animal_index};

            
            filename_pattern_cam1 = sprintf('%s_%s_%dDLC_Resnet50_CAM1(3 bp)Mar13shuffle1_snapshot_200.csv', day, animal, epoch-1);
            filename_pattern_cam2 = sprintf('%s_%s_%dDLC_resnet50_CAM 2 (3bp)Mar23shuffle1_100000.csv', day, animal, epoch-1);
            cam1_filename = fullfile(bd1path, filename_pattern_cam1);
            cam2_filename = fullfile(bd2path, filename_pattern_cam2);
                
            fr_1 = 29.97; fr_2 = 29.97;
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
save(fullfile(savePath, 'spatial_learning_DLC.mat'), 'dat_all');

end
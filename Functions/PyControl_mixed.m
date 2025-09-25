function PyControl_mixed(design_mat, data_path)
%%
% Generate your design matrix in the format of N(animal) x D(days) and save
% it as an xlsx file
opts = detectImportOptions(design_mat, 'TextType','string', 'ReadVariableNames', true);
Ifvalid = readtable(design_mat, 'Sheet','IfValid', 'ReadVariableNames', true); valid_mat = Ifvalid{1:end, 2:end};

Dates = readtable(design_mat, opts); cue_dates = Dates{1:end,2:end};
Animals = cellstr(Dates{:, 1}');
% Window size to calculate block accuracy
window_size = 10;

cue_learning_BA = cell(size(Animals, 2), size(cue_dates, 2), 2);
cue_learning_entropy = zeros(size(Animals, 2), size(cue_dates, 2), 2);
cue_learning_probetest = zeros(size(Animals, 2), size(cue_dates, 2), 2);
cue_learning_accuracy = nan(size(Animals, 2), size(cue_dates, 2), 2);
cue_learning_pokenumber = nan(size(Animals, 2), size(cue_dates, 2), 2);
cue_learning_pokescorrect = cell(size(Animals, 2), size(cue_dates, 2), 2);

for animal_index = 1:size(Animals, 2)
    animalID = Animals(animal_index);

    for date_index = 1:size(cue_dates, 2)
        date = cue_dates(animal_index, date_index);
        date = string(date);
        folderPath = fullfile(data_path, 'PyControl', date);
        if ismissing(date)
            continue;
        end




        for epoch = 1:2
            if valid_mat(animal_index, date_index)
                folderPath = fullfile(data_path, 'Pycontrol', date);
                tsvFiles = dir(fullfile(folderPath, '*.tsv'));
                if epoch == 2
                    animalID_temp = strcat(animalID, '_1');
                    TSVfname = find_tsv(folderPath, animalID);
                else
                    animalID_temp = strcat(animalID, '_0');
                    TSVfname = find_tsv(folderPath, animalID_temp);
                end
                active_ports = find_correct_port(TSVfname);
                if ~isnan(active_ports)
                    break
                end
            end
        end






        for epoch = 1:2
            if epoch == 2
                TSVfname = find_tsv(folderPath, strcat(animalID, '_1'));
            else
                TSVfname = find_tsv(folderPath, strcat(animalID, '_0'));
            end
            
            if ~TSVfname
                continue;
            end
            df = readtable(TSVfname, "FileType","text",'Delimiter', '\t');

            filtered_df = raw_df_filter(df);
            mapping_1 = containers.Map({'A_poke', 'B_poke', 'C_poke', 'D_poke'}, [1, 2, 3, 4]);
            pokes = arrayfun(@(x) mapping_1(x{1}), filtered_df.content, 'UniformOutput', true);

            poke_correct = ismember(pokes, active_ports);
            cue_learning_probetest(animal_index, date_index, epoch) = sum(poke_correct(1:2))/2;
            block_accuracy = compute_block_accuracy(poke_correct, window_size);
            if length(block_accuracy) > 5
                block_accuracy = block_accuracy(1:5);
            end
            % Optional, select the first 20 trials to represent accuracy of
            % an epoch
            if numel(pokes) > 20
                pokes = pokes(1:20);
            end
            cue_learning_pokenumber(animal_index, date_index, epoch) = numel(pokes);
            
            cue_learning_BA{animal_index, date_index, epoch} = block_accuracy;
            cue_learning_accuracy(animal_index, date_index, epoch) = sum(poke_correct)/numel(poke_correct);
            cue_learning_pokescorrect{animal_index, date_index, epoch} = poke_correct;

            [~, ~, idx] = unique(pokes);
            counts = accumarray(idx, 1);
            proportions = counts / length(pokes);
            entropy = 0;
            p = proportions;
            for i = 1:length(p)
                if p(i) > 0
                    entropy = entropy + p(i) * log2(1 / p(i));
                end
            end
           
            cue_learning_entropy(animal_index, date_index, epoch) = entropy;
        end

    end
end

cue_learning_BA = squeeze(cue_learning_BA);
cue_learning_entropy = squeeze(cue_learning_entropy); cue_learning_entropy(cue_learning_entropy == 0) = NaN;
savePath = fullfile(data_path, 'Output');
save(fullfile(savePath, 'mixed_learning_PC.mat'), 'cue_learning_BA', 'cue_learning_entropy', 'cue_learning_accuracy', 'cue_learning_pokenumber', 'cue_learning_pokescorrect', 'cue_learning_probetest');


end
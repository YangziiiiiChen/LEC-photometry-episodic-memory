function FormStandardData_spatial(design_mat, data_path)

Dates = readtable(design_mat, 'TextType', 'string', 'ReadVariableNames', true); cue_dates = Dates{1:end, 2:end};
Ifvalid = readtable(design_mat, 'Sheet','IfValid', 'ReadVariableNames', true); valid_mat = Ifvalid{1:end, 2:end};
Animals = cellstr(Dates{1:end, 1}');
mapping_XaxisToBin = containers.Map({'12', '23', '34', '41', '21', '32', '43', '14'}, [1 0 1 0 1 0 1 0]);

for animal_index = 1:size(Animals,2)
    for date_index = 1:size(cue_dates,2)
        animal = Animals{animal_index};
        date = string(cue_dates(animal_index, date_index));
        for epoch = 1:2
            if valid_mat(animal_index, date_index)
                folderPath = fullfile(data_path, 'Pycontrol', date);
                tsvFiles = dir(fullfile(folderPath, '*.tsv'));
                if epoch == 2
                    animalID = strcat(animal, '_1');
                    TSVfname = find_tsv(folderPath, animalID);
                else
                    animalID = strcat(animal, '_0');
                    TSVfname = find_tsv(folderPath, animalID);
                end
                FP_folder_name = fullfile(data_path, 'Photometry Data', strcat(strcat(date, '_'), animalID ));
                FP_folder_name = char(FP_folder_name);

                if ~exist(FP_folder_name) || (islogical(TSVfname) && TSVfname == 0)
                    continue;
                end

                data = TDTbin2mat(FP_folder_name);
                fs = data.streams.GFPG.fs;

                if isempty(data.epocs)
                    continue;
                end

                onset = data.epocs.x1EN_.onset;
                GFP = double(data.streams.GFPG.data); GCAMP = double(data.streams.GCMG.data);
                timestamp = (1:length(GFP))/fs - onset(1);
                
                % just in case very few epochs have inconsistent dimensions
                min_len = min(length(GFP), length(GCAMP));
                GFP   = GFP(1:min_len);
                GCAMP = GCAMP(1:min_len);

                PhotometryData.GFP = GFP;
                PhotometryData.GCAMP = GCAMP;
                PhotometryData.timestamp = timestamp;


                df = readtable(TSVfname, "FileType","text",'Delimiter', '\t');
                filtered_df = raw_df_filter(df);
                poke_times = filtered_df.time;

                reward_labels = {'A_reward', 'B_reward', 'C_reward', 'D_reward'};
                reward_rows = ismember(df.content, reward_labels);
                filtered_df = df(reward_rows, :);
                time_correct = filtered_df.time;
                PyControlData.poke_times = poke_times;
                PyControlData.time_correct = time_correct;

                load(fullfile(data_path, 'Output', 'spatial_learning_DLC.mat'));
                DLC_dat = dat_all{date_index, epoch, animal_index};
                if isempty(DLC_dat)
                    continue;
                end
                trial_cut_result = TrialCut(DLC_dat);
                idx_r = find_correct_port(TSVfname);
                idx_ur = setdiff([1 2 3 4], idx_r);
                mapping_pathtoport = containers.Map({'12', '23', '34', '41', '21', '32', '43', '14'}, [2, 3, 4, 1, 2, 3, 4, 1]);
                num_r = 1; num_ur = 1;
                clear DLC_r DLC_ur
                for i = 1:numel(trial_cut_result)
                    type = trial_cut_result(i).trialtype;
                    DLC_divided = trial_cut_result(i).DLC_dat;

                    if isKey(mapping_pathtoport, type)
                        port = mapping_pathtoport(type);
                    else
                        continue;
                    end

                    if ismember(port, idx_r)
                        DLC_r{1, num_r} = DLC_divided;
                        DLC_r{2, num_r} = type;
                        num_r = num_r + 1;
                    elseif ismember(port, idx_ur)
                        DLC_ur{1, num_ur} = DLC_divided;
                        DLC_ur{2, num_ur} = type;
                        num_ur = num_ur + 1;
                    end
                end

                DLC_rewarded = {};
                if ~exist('DLC_r','var')
                    continue;
                end
                valid_idx = 1;

                for i = 1:size(DLC_r,2)
                    temp_rewarded.entry_time = DLC_r{1,i}(1,4);
                    temp_rewarded.exit_time = DLC_r{1,i}(end,4);
                    temp_rewarded.raw_X = DLC_r{1,i}(:,1);
                    temp_rewarded.raw_Y = DLC_r{1,i}(:,2);
                    temp_rewarded.timestamps = DLC_r{1,i}(:,4);
                    temp_rewarded.convert_X = DLC_r{1,i}(:,5);
                    temp_rewarded.convert_Y = DLC_r{1,i}(:,6);
                    temp_rewarded.type = DLC_r{2,i};
                    temp_rewarded.speed = DLC_r{1,i}(:,3);

                    ifpoke = [temp_rewarded.entry_time - poke_times, temp_rewarded.exit_time - poke_times];
                    if any(ifpoke(:,1) .* ifpoke(:,2) < 0)
                        temp_rewarded.ifpoke = 1;
                    else
                        temp_rewarded.ifpoke = 0;
                    end

                    ifreward = [temp_rewarded.entry_time - time_correct, temp_rewarded.exit_time - time_correct];
                    if any(ifreward(:,1) .* ifreward(:,2) < 0)
                        temp_rewarded.ifreward = 1;
                    else
                        temp_rewarded.ifreward = 0;
                    end

                    if temp_rewarded.ifpoke == 1 && temp_rewarded.ifreward == 0
                        continue;
                    end

                    type = DLC_r{2,i};
                    if mapping_XaxisToBin(type)
                        temp_rewarded.spatial_bin = spatial_bins(temp_rewarded.convert_X, 24);
                    else
                        temp_rewarded.spatial_bin = spatial_bins(temp_rewarded.convert_Y, 24);
                    end
                    avg_speed = calculateBinMeans([temp_rewarded.spatial_bin temp_rewarded.speed]);
                    temp_rewarded.avg_speed = avg_speed(:,2);
                    DLC_rewarded{valid_idx} = temp_rewarded;
                    valid_idx = valid_idx + 1;
                end

                DLCData_rewarded = DLC_rewarded';

                for i = 1:size(DLC_ur, 2)
                    temp_unrewarded.entry_time = DLC_ur{1, i}(1, 4);
                    temp_unrewarded.exit_time = DLC_ur{1, i}(end, 4);
                    temp_unrewarded.raw_X = DLC_ur{1, i}(:, 1);
                    temp_unrewarded.raw_Y = DLC_ur{1, i}(:, 2);
                    temp_unrewarded.timestamps = DLC_ur{1, i}(:, 4);
                    temp_unrewarded.convert_X = DLC_ur{1, i}(:, 5);
                    temp_unrewarded.convert_Y = DLC_ur{1, i}(:, 6);
                    temp_unrewarded.type = DLC_ur{2,i};
                    temp_unrewarded.speed = DLC_ur{1,i}(:,3);
                    ifpoke = [temp_unrewarded.entry_time-poke_times temp_unrewarded.exit_time-poke_times];
                    if any(ifpoke(:,1).*ifpoke(:,2)<0)
                        temp_unrewarded.ifpoke = 1;
                    else
                        temp_unrewarded.ifpoke = 0;
                    end
                    ifreward = [temp_unrewarded.entry_time-time_correct temp_unrewarded.exit_time-time_correct];
                    if any(ifreward(:,1).*ifreward(:,2)<0)
                        temp_unrewarded.ifreward = 1;
                    else
                        temp_unrewarded.ifreward = 0;
                    end
                    type = DLC_ur{2,i};
                    if mapping_XaxisToBin(type)
                        temp_unrewarded.spatial_bin = spatial_bins(temp_unrewarded.convert_X, 24);
                    else
                        temp_unrewarded.spatial_bin = spatial_bins(temp_unrewarded.convert_Y, 24);
                    end
                    type = DLC_ur{2,i};
                    if mapping_XaxisToBin(type)
                        temp_unrewarded.spatial_bin = spatial_bins(temp_unrewarded.convert_X, 24);
                    else
                        temp_unrewarded.spatial_bin = spatial_bins(temp_unrewarded.convert_Y, 24);
                    end
                    avg_speed = calculateBinMeans([temp_unrewarded.spatial_bin temp_unrewarded.speed]);
                    temp_unrewarded.avg_speed = avg_speed(:,2);
                    DLC_unrewarded{i} = temp_unrewarded;
                end
                DLCData_unrewarded = DLC_unrewarded';
                date_formatted = strcat(date, '25');
                savePath = fullfile(data_path, 'Output\Raw Data');
                filename = sprintf('%s_%s_LEC2PFC_E%d.mat', date_formatted, animal, epoch);
                save(fullfile(savePath, filename), 'PhotometryData', 'PyControlData', 'DLCData_unrewarded', 'DLCData_rewarded');
            end
        end
    end
end


end
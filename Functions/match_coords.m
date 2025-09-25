function result = match_coords(cam1_filename, cam2_filename, fr_1, fr_2)
    num_bins_BD = 24; % P2 and P4 longer (9)
    num_bins_AC = 24; % P1 and P3 shorter (7)

    P1 = [
        321, -268;
        375, -268;
        375, -1;
        321, -1
    ]; 
    P1_std = [
      65, 15;
      80, 15;
      80, 73;
      65, 73
    ];
    C1 = [
        317, -262.5;
        362, -262.5;
        362, -316;
        317, -316
    ]; % bottom-right corner as C1
    C1_std = [
        64.7, 15.8;
        80, 15.8;
        80, 0;
        64.7, 0
    ];
    
    
    P2 = [
        50, -302;
        363, -310;
        366, -270;
        53, -262
    ];
    P2_std = [
      0, 0;
      80, 0;
      80, 15;
      0, 15
    ];
    C2 = [
        41, -250;
        86, -250;
        86, -300;
        41, -300
    ]; % bottom-left corner as C2
    C2_std = [
        0, 15;
        15, 15;
        15, 0;
        0, 0
    ];

    
    P3 = [
        294, -478;
        343, -478;
        343, -141;
        294, -141
    ];
    P3_std = [
      0, 15;
      15, 15;
      15, 65;
      0, 65
    ];
    C3 = [
        265, -56;
        299, -56;
        299, -98;
        265, -98
    ]; % top-left corner as C3
    C3_std = [
        0, 80;
        15, 80;
        15, 65;
        0, 65
    ];
    
    P4 = [
        294, -141;
        638, -141;
        638, -80;
        294, -80
    ]; 
    P4_std = [
      0, 65;
      65, 65;
      65, 80;
      0, 80
    ];
    C4 = [
        525, -81;
        560, -81;
        560, -123;
        525, -123
    ]; % top-right corner as C4
    C4_std = [
        65, 80;
        80, 80;
        80, 65;
        65, 65
    ];
    
    filename = cam2_filename;
    if ~isfile(filename)
        warning('File does not exist: %s', filename);
        result = 1; 
        return; 
    end
    opts = detectImportOptions(filename);
    opts.VariableNames = { ...
        'scorer', 'nose_x', 'nose_y', 'likelihood_1', ...
        'LE_x', 'LE_y', 'likelihood_2', ...
        'RE_x', 'RE_y', 'likelihood_3', ...
        'TB_x', 'TB_y', 'likelihood_4' ...
    };
    
    dat_cam2 = readtable(filename, opts);
    dat_cam2.time = dat_cam2.scorer / fr_2;
    %dat_cam2 = dat_cam2(dat_cam2.time < trial_cut_time, :);

    minutes = floor(dat_cam2.time / 60);
    seconds = floor(mod(dat_cam2.time, 60));
    milliseconds = floor((dat_cam2.time - floor(dat_cam2.time)) * 1000);
    
    
    dat_cam2.formatted_time = strcat(num2str(minutes, '%02d'), ':', ...
                                     num2str(seconds, '%02d'), ':', ...
                                     num2str(milliseconds, '%03d'));
    dat_cam2(1:2, :) = [];
    dat_cam2(dat_cam2.likelihood_1 < 0.8, :) = [];
    dat_cam2.nose_y = -dat_cam2.nose_y; dat_cam2.LE_y = -dat_cam2.LE_y; dat_cam2.RE_y = -dat_cam2.RE_y; dat_cam2.TB_y = -dat_cam2.TB_y;
    coords_cam2 = [dat_cam2.nose_x, dat_cam2.nose_y, dat_cam2.time];
    
    inP1_cam2 = points_in_polygon_mask(coords_cam2, P1);
    inP2_cam2 = points_in_polygon_mask(coords_cam2, P2);
    inP2_cam2((inP2_cam2 == 1) & (inP1_cam2 == 1)) = 0;

    coords_P1_cam2 = coords_cam2(inP1_cam2, :);  points_in_polygon = coords_P1_cam2(:,1:2);
    P1_mapped_points = map_points_to_rectangle(P1, P1_std, points_in_polygon);
    nose_x = P1_mapped_points(:,1);
    nose_y = P1_mapped_points(:,2);
    nose_x_raw = coords_P1_cam2(:,1);
    nose_y_raw = coords_P1_cam2(:,2);
    speed = sqrt((nose_x - [NaN; nose_x(1:end-1)]).^2 + (nose_y - [NaN; nose_y(1:end-1)]).^2);
    speed(isnan(speed)) = 0;
    coords_P1_cam2 = [nose_x_raw, nose_y_raw, medfilt1(speed * fr_2, 10), coords_P1_cam2(:,3) P1_mapped_points];
    coords_P1_cam2 = [coords_P1_cam2 spatial_bins(coords_P1_cam2(:,6), num_bins_AC)];


    coords_P2_cam2 = coords_cam2(inP2_cam2, :);  points_in_polygon = coords_P2_cam2(:,1:2);
    P2_mapped_points = map_parallelogram_to_rectangle(P2, P2_std, points_in_polygon);
    nose_x = P2_mapped_points(:,1);
    nose_y = P2_mapped_points(:,2);
    nose_x_raw = coords_P2_cam2(:,1);
    nose_y_raw = coords_P2_cam2(:,2);
    speed = sqrt((nose_x - [NaN; nose_x(1:end-1)]).^2 + (nose_y - [NaN; nose_y(1:end-1)]).^2);
    speed(isnan(speed)) = 0;
    coords_P2_cam2 = [nose_x_raw, nose_y_raw, medfilt1(speed * fr_2, 10), coords_P2_cam2(:,3) P2_mapped_points];
    coords_P2_cam2 = [coords_P2_cam2 spatial_bins(coords_P2_cam2(:,5), num_bins_BD)];
    
    %% cam1
    filename = cam1_filename;
    if ~isfile(filename)
        warning('File does not exist: %s', filename);
        result = 1; 
        return; 
    end
    opts = detectImportOptions(filename);
    opts.VariableNames = { ...
        'scorer', 'nose_x', 'nose_y', 'likelihood_1', ...
        'LE_x', 'LE_y', 'likelihood_2', ...
        'RE_x', 'RE_y', 'likelihood_3', ...
        'TB_x', 'TB_y', 'likelihood_4' ...
    };
    dat_cam1 = readtable(filename, opts);
    dat_cam1.time = dat_cam1.scorer / fr_1;
    %dat_cam1 = dat_cam1(dat_cam1.time < trial_cut_time, :);

    minutes = floor(dat_cam1.time / 60);
    seconds = floor(mod(dat_cam1.time, 60));
    milliseconds = floor((dat_cam1.time - floor(dat_cam1.time)) * 1000);
    
    
    dat_cam1.formatted_time = strcat(num2str(minutes, '%02d'), ':', ...
                                     num2str(seconds, '%02d'), ':', ...
                                     num2str(milliseconds, '%03d'));
    dat_cam1(1:2, :) = [];
    dat_cam1(dat_cam1.likelihood_1 < 0.8, :) = [];
    dat_cam1.nose_y = -dat_cam1.nose_y; dat_cam1.LE_y = -dat_cam1.LE_y; dat_cam1.RE_y = -dat_cam1.RE_y; dat_cam1.TB_y = -dat_cam1.TB_y;
    coords_cam1 = [dat_cam1.nose_x, dat_cam1.nose_y, dat_cam1.time];
    
    inP3_cam1 = points_in_polygon_mask(coords_cam1, P3);
    inP4_cam1 = points_in_polygon_mask(coords_cam1, P4);
    inP4_cam1((inP4_cam1 == 1) & (inP3_cam1 == 1)) = 0;
    
    coords_P3_cam1 = coords_cam1(inP3_cam1, :);  points_in_polygon = coords_P3_cam1(:,1:2);
    P3_mapped_points = map_points_to_rectangle(P3, P3_std, points_in_polygon);
    nose_x = P3_mapped_points(:,1);
    nose_y = P3_mapped_points(:,2);
    nose_x_raw = coords_P3_cam1(:,1);
    nose_y_raw = coords_P3_cam1(:,2);
    speed = sqrt((nose_x - [NaN; nose_x(1:end-1)]).^2 + (nose_y - [NaN; nose_y(1:end-1)]).^2);
    speed(isnan(speed)) = 0;
    coords_P3_cam1 = [nose_x_raw, nose_y_raw, medfilt1(speed * fr_2, 10), coords_P3_cam1(:,3) P3_mapped_points];
    coords_P3_cam1 = [coords_P3_cam1 spatial_bins(coords_P3_cam1(:,6), num_bins_AC)];

    coords_P4_cam1 = coords_cam1(inP4_cam1, :);  points_in_polygon = coords_P4_cam1(:,1:2);
    P4_mapped_points = map_points_to_rectangle(P4, P4_std, points_in_polygon);
    nose_x = P4_mapped_points(:,1);
    nose_y = P4_mapped_points(:,2);
    nose_x_raw = coords_P4_cam1(:,1);
    nose_y_raw = coords_P4_cam1(:,2);
    speed = sqrt((nose_x - [NaN; nose_x(1:end-1)]).^2 + (nose_y - [NaN; nose_y(1:end-1)]).^2);
    speed(isnan(speed)) = 0;
    coords_P4_cam1 = [nose_x_raw, nose_y_raw, medfilt1(speed * fr_1, 10), coords_P4_cam1(:,3) P4_mapped_points];
    coords_P4_cam1 = [coords_P4_cam1 spatial_bins(coords_P4_cam1(:,5), num_bins_BD)];
    

    all_coords = [coords_P1_cam2; coords_P2_cam2; coords_P3_cam1; coords_P4_cam1];
    [~, idx] = sort(all_coords(:, 4));
    all_coords_sorted = all_coords(idx, :);
    all_coords_sorted(points_in_corners_mask(all_coords_sorted, C1_std), 9) = 1;
    all_coords_sorted(points_in_corners_mask(all_coords_sorted, C2_std), 9) = 2;
    all_coords_sorted(points_in_corners_mask(all_coords_sorted, C3_std), 9) = 3;
    all_coords_sorted(points_in_corners_mask(all_coords_sorted, C4_std), 9) = 4;

    result = struct( ...
        'P1', coords_P1_cam2, ...
        'P2', coords_P2_cam2, ...
        'P3', coords_P3_cam1, ...
        'P4', coords_P4_cam1, ...
        'All', all_coords_sorted ...
    );

end

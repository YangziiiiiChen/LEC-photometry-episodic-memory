addpath('Functions');
addpath('Functions\Plot');
close all;
clear;
%% block accuracy
PyControlFileName = 'Data\Yangzi\Output\spatial_learning_PC.mat';
figure_handle = block_accuracy_plot(PyControlFileName);
savepath = 'Data\Yangzi\Output\Figure';
exportgraphics(figure_handle, fullfile(savepath, 'block_accuracy_plot.png'), 'Resolution', 1000);

%% plot speed data of one specific day based on different trial types 
Design_spreadsheet_name = '4546_Fiber_Spatial2.xlsx';
Raw_data_path = 'Data\Mansour\Output\Raw Data';
day = 5;
figure_handle = speed_plot_trial_type(Design_spreadsheet_name, Raw_data_path, day);

savepath = 'Data\Mansour\Figure';
figname = 'test.png';
exportgraphics(figure_handle, fullfile(savepath, figname), 'Resolution', 400);

%% speed plot based on path types (Rewarded vs Unrewarded)

DLCFileName = '';
Raw_data_path = '';
day = 1;
figure_handle = speed_plot_trial_type(DLCFileName, Raw_data_path, day);

savepath = '';
figname = '.png';
exportgraphics(figure_handle, fullfile(savepath, figname), 'Resolution', 400);

%% Trajectory heatmap. DLCData should be one cell from the variable 'dat_all'

figure_handle = speed_plot_trial_type(DLCData);

savepath = '';
figname = '.png';
exportgraphics(figure_handle, fullfile(savepath, figname), 'Resolution', 400);

%% Raster plot based on time

design_mat_name = 'Spatial_date_batch58.xlsx';
data_path = 'Data\Yangzi';
type = 'Photometry_hit'; % Photometry_hit/Photometry_miss/Photometry_correct_rejection/Photometry_false_alarm
figure_handles = raster_plot_time_per_epoch(design_mat_name, data_path, type);

%% Raster plot based on time (RANKED)
design_mat_name = 'Spatial_date_batch58.xlsx';
data_path = 'Data\Yangzi';
type = 'Photometry_hit';
f = raster_plot_peak_ranked_per_epoch(design_mat_name, data_path, type);
%% Raster plot based on location


design_mat_name = '4546_Fiber_Spatial2 - validated.xlsx';
data_path = 'Data\Mansour';
type = 'Photometry_hit'; % Photometry_hit/Photometry_miss/Photometry_correct_rejection/Photometry_false_alarm
figure_handles = raster_plot_location_per_epoch(design_mat_name, data_path, type);


%% Distribution of dFF (comparison between 400mA and 800mA days)
Data = dFoF;
dFoF = Data(1000*60:1000*90);
figure;
ID = min(dFoF):1.5e-04:max(dFoF);plot(ID, histc(dFoF, ID));
data = dFoF;
threshold = quantile(data, 0.95);
mean_top10_1 = mean(data(data >= threshold));
hold on;
dFoF = Data(1000*120:1000*150);ID = min(dFoF):1.5e-04:max(dFoF);plot(ID, histc(dFoF, ID));
data = dFoF;
threshold = quantile(data, 0.95);
mean_top10_2 = mean(data(data >= threshold));
xlim([-0.02 0.04]);
ylim([0 2000]);
legend({'test', 'real'});
stats_text = {
    sprintf('Test: top mean = %.2f', mean_top10_1)
    sprintf('Active: top mean = %.2f', mean_top10_2)
};

% Add the text to the figure
text(.02, 1200, stats_text, 'FontSize', 20);
stats_text = {
    sprintf('Test: %s', "60-90")
    sprintf('Real : %s', "120-150")
};

% Add the text to the figure
text(0, 1600, stats_text, 'FontSize', 20);
[h,p,ks2stat] = kstest2(dFoF, dFoF);


%%

design_mat_name = '4546_Fiber_Spatial2 - validated.xlsx';
data_path = 'Data\Mansour';
type = 'Photometry_hit'; % Photometry_hit/Photometry_miss/Photometry_correct_rejection/Photometry_false_alarm
figure_handles = raster_plot_time_average(design_mat_name, data_path, type);


%%

raster_plot_location_average(design_mat_name, data_path, type)


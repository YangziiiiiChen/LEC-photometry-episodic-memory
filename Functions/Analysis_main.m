% function m-file to calculate deltaF/F from raw GFP and GCAMP signals
%
% INPUT ---- fname: the name of matlab file storing the raw signal values.
%            ofname: the name of file to store the dF/F and timestamps
%
% written by Y.C. in July 2025

addpath('Functions\TDTSDK\TDTbin2mat');
addpath('Functions');
clear;
choice = questdlg('Please select the data type:', ...
                  'Data Type Selection', ...
                  'Spatial learning', 'Mixed session', 'Spatial learning');

if isempty(choice)
    disp('User canceled the type selection.');
    return;
end

[filename, pathname] = uigetfile('*.xlsx', 'Select the design matrix file');
if isequal(filename, 0)
    disp('User canceled file selection.');
    return;
end
design_mat = fullfile(pathname, filename);

data_path = uigetdir('', 'Select the data folder');
if isequal(data_path, 0)
    disp('User canceled folder selection.');
    return;
end

switch choice
    case 'Mixed session'
        disp('Not done. Please select spatial');
        return;
    case 'Spatial learning'
        disp('Processing spatial-type data...');
        DLC_spatial(design_mat, data_path);
        disp('DLC analysis done!');
        PyControl_spatial(design_mat, data_path);
        disp('PyControl analysis done!');
        input_ws = inputdlg('Enter half window size for time-based analysis:', 'Input', [1 50]);
        half_window_size = str2double(input_ws{1}); 
        FormStandardData_spatial(design_mat, data_path);
        disp('Form standard data done!');
        dFF(design_mat, data_path);
        disp('dFF calculation');
        FPAnalysis_time(design_mat, data_path, half_window_size);
        disp('Time-based analysis done');
        FPAnalysis_location(design_mat, data_path);
end

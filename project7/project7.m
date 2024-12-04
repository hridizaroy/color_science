%% Project 7 Report
% Team 5: Shakira Garnett, Hridiza Roy

%% Initialization
clear all; close all; clc;

% load the CIE observer and illuminant data
cie = loadCIEdata;

%% Step 1
cam_RGBs_orig = load("Cam_RGBs.txt");
cam_RGBs = uint8((double(cam_RGBs_orig) / 255.0) * 100);

table4ti1 = [(1:30)', [cam_RGBs'; zeros(3, 3); 100 * ones(3, 3)] ];

uncal_XYZs = importdata("workflow_test_uncal.ti3",' ',20);

uncal_patches_XYZ = uncal_XYZs.data(1:24, 5:7);
uncal_disp_black_XYZ = uncal_XYZs.data(25:27, 5:7);
uncal_disp_white_XYZ = uncal_XYZs.data(28:30, 5:7);

uncal_XYZk = mean(uncal_disp_black_XYZ, 1);
uncal_XYZw = mean(uncal_disp_white_XYZ, 1);

uncal_display_Labs = XYZ2Lab(uncal_patches_XYZ', uncal_XYZw');

% Columns 5-7 for Lab values, transpose to make it 3x24
data = load('munki_CC_XYZs_Labs.txt');
munki_Labs = data(:, 5:7)';

deltaEs_uncal = deltaEab(uncal_display_Labs, munki_Labs);
min_deltaEs_uncal = min(deltaEs_uncal);
max_deltaEs_uncal = max(deltaEs_uncal);
mean_deltaEs_uncal = mean(deltaEs_uncal);

print_uncalibrated_workflow_error(munki_Labs, uncal_display_Labs, deltaEs_uncal);

%% Step 2
cam_XYZs = camRGB2XYZ('cam_model.mat', cam_RGBs_orig);

XYZn_D50 = ref2XYZ(cie.PRD, cie.cmf2deg, cie.illD50);
disp_RGBs = XYZ2dispRGB('display_model.mat', cam_XYZs, XYZn_D50);

disp_RGBs = uint8((double(disp_RGBs) / 255.0) * 100);
table4ti1 = [(1:30)', [disp_RGBs'; zeros(3, 3); 100 * ones(3, 3)] ];

cal_XYZs = importdata('workflow_test_cal.ti3',' ',20);

cal_CC_patches_XYZ = cal_XYZs.data(1:24, 5:7);
cal_disp_black_XYZ = cal_XYZs.data(25:27, 5:7);
cal_disp_white_XYZ = cal_XYZs.data(28:30, 5:7);

cal_XYZk = mean(cal_disp_black_XYZ, 1);
cal_XYZw = mean(cal_disp_white_XYZ, 1);

cal_display_Labs = XYZ2Lab(cal_CC_patches_XYZ', cal_XYZw');

deltaEs_cal = deltaEab(cal_display_Labs, munki_Labs);
min_deltaEs_cal = min(deltaEs_cal);
max_deltaEs_cal = max(deltaEs_cal);
mean_deltaEs_cal = mean(deltaEs_cal);

print_calibrated_workflow_error(munki_Labs, cal_display_Labs, deltaEs_cal);

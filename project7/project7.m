%% Project 7 Report
% Team 5: Shakira Garnett, Hridiza Roy

cd ../color_toolbox/

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

%% Step 3

% Load the data
data = load('munki_CC_XYZs_Labs.txt');

% Separate into XYZ and Lab arrays
munki_XYZs = data(:, 2:4)';

% Create the color transformation structure for XYZ to sRGB
% cform = makecform('xyz2srgb');

% % Apply the color transformation
% munki_RGBs = applycform(munki_XYZs', cform) % Transpose back for correct input format

munki_RGBs = xyz2rgb(munki_XYZs');

% Rescale RGB values from 0-100 to 0-255
munki_RGBs_rescaled = munki_RGBs * (255 / 100);

% Convert to unsigned 8-bit integers
munki_RGBs_uint8 = uint8(munki_RGBs_rescaled);

% THIS IS DUMMY DATA THAT NEEDS TO BE REPLACED BY THE ACTUAL
% VALUES ACHIVED FROM STEPS 2a AND 2c AS STATED IN THE WRITE UP
% THESE VARIABLES MUST BE CHANAGED DO NOT LEAVE THEM AS THEY ARE!!!
% Create dummy data for the 24 RGB values (replace these with actual values once you have them)
ground_truth_RGBs = munki_RGBs'  % Random RGB values for ground truth
uncalibrated_RGBs = cam_RGBs_orig  % Random RGB values for uncalibrated
calibrated_RGBs = cam_XYZs     % Random RGB values for calibrated

% ground_truth_row = zeros([1,12,3])
% for i = [1,12]
%     ground_truth_row(i) = ground_truth_RGBs_uint8(1,:)    
% end


% % Visualize the result
% figure;
% imshow(workflow_diffs);
% title('Ground-Truth, Uncalibrated, and Calibrated RGB Values');
% axis off;

% % Resize the final image to 768x1024 (if needed)
% workflow_diffs_resized = imresize(workflow_diffs, [768, 1024], 'nearest');

% % Save the resized image as a PNG
% imwrite(workflow_diffs_resized, 'workflow_diffs.png');

%% Step 4
% Load the original ColorChecker image
% img_orig = imread("chart.jpg");

% % Reshape the image into a pixel vector
% [r, c, p] = size(img_orig);  % Get the dimensions of the image
% pix_orig = reshape(img_orig, [r*c, p])';  % Reshape to 3x(rows*cols)

% % Process the pixels through camRGB2XYZ and XYZ2dispRGB
% % camRGB2XYZ is assumed to take the RGB values and convert to XYZ
% % save the (extended) camera model for use in later projects
% save('cam_model.mat', 'cam_polys', 'cam_matrix3x11');
% pix_XYZ = camRGB2XYZ('cam_model.mat', pix_orig');  % Convert RGB to XYZ, pix_orig' is 3xN

% % XYZ2dispRGB will take the XYZ values and convert to calibrated RGB
% pix_DCs_calib = XYZ2dispRGB(pix_XYZ);  % Convert XYZ to color-calibrated RGB

% % Reshape the processed pixels back into an image
% img_calib = reshape(pix_DCs_calib', [r, c, p]);  % Reshape back to original dimensions

% % Save the color-calibrated image as a .png file
% imwrite(img_calib, 'color_calibrated_image.png');

% % Display the color-calibrated image
% imshow(img_calib);
% title('Color-Calibrated Image');

cd ../project7/


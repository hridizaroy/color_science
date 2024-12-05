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

data = load('munki_CC_XYZs_Labs.txt');
% Columns 5-7 for Lab values, transpose to make it 3x24
munki_Labs = data(:, 5:7)';

deltaEs_uncal = deltaEab(uncal_display_Labs, munki_Labs);
min_deltaEs_uncal = min(deltaEs_uncal);
max_deltaEs_uncal = max(deltaEs_uncal);
mean_deltaEs_uncal = mean(deltaEs_uncal);

print_uncalibrated_workflow_error(munki_Labs, uncal_display_Labs, deltaEs_uncal);

%% Step 2
cam_XYZs = camRGB2XYZ('cam_model.mat', cam_RGBs_orig);

XYZn_D50 = ref2XYZ(cie.PRD, cie.cmf2deg, cie.illD50);
disp_RGBs_orig = XYZ2dispRGB('display_model.mat', cam_XYZs, XYZn_D50);

disp_RGBs = uint8((double(disp_RGBs_orig) / 255.0) * 100);
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

% Get XYZ values
munki_XYZs = data(:, 2:4);

% Create the color transformation structure for XYZ to sRGB
cform = makecform('xyz2srgb', "AdaptedWhitePoint", XYZn_D50');

% Apply the color transformation
munki_RGBs = applycform(double(munki_XYZs), cform);

% Rescale RGB values from 0-100 to 0-255
munki_RGBs_uint8 = uint8(munki_RGBs * 255);

% Repeat rows of ground truth to create 48 x 3 matrix
top_row = reshape([munki_RGBs_uint8'; munki_RGBs_uint8'], [3, 48])';

% combine calibrated and uncalibrated data in an alternating fashion
bottom_row = reshape([cam_RGBs_orig; disp_RGBs_orig], [3, 48])';

% combine the top and bottom rows and reshape them
workflow_diffs = pagetranspose(reshape([reshape(top_row, [12, 4, 3]); ...
                    reshape(bottom_row, [12, 4, 3])], [12, 8, 3]));

% Resize the final image to 768 x 1024
workflow_diffs_resized = imresize(workflow_diffs, [768, 1024],'nearest');

% Visualize the result
figure;
imshow(workflow_diffs_resized);
title('Ground-Truth, Uncalibrated, and Calibrated RGB Values');
axis off;

% Save the resized image as a PNG
imwrite(workflow_diffs_resized, 'workflow_diffs.png');

%% Step 4

% Load the original ColorChecker image
img_orig = imread("chart.jpg");

% Reshape the image into a pixel vector
[r, c, p] = size(img_orig);  % Get the dimensions of the image
pix_orig = reshape(img_orig, [r*c, p])';  % Reshape to 3x(rows*cols)

% Convert RGB to XYZ, pix_orig' is 3xN
pix_XYZ = camRGB2XYZ('cam_model.mat', pix_orig);

% XYZ2dispRGB will take the XYZ values and convert to calibrated RGB
pix_DCs_calib = XYZ2dispRGB('display_model.mat', pix_XYZ, XYZn_D50);

% Reshape the processed pixels back into an image
img_calib = reshape(pix_DCs_calib', [r, c, p]);

% Save the color-calibrated image as a .png file
imwrite(img_calib, 'color_calibrated_image.png');

% Show original image
figure;
imshow(img_orig);
title('original image');

% Visualize the result
figure;
% Display the color-calibrated image
imshow(img_calib);
title('color-calibrated image');

%% Feedback
% i. Who did which parts
%
% Shakira - 3, 4
%
% Hridiza - 1, 2, 3 (minor)
%
% ii. Problems
%
% - Creating the matrix for part 3 was very tricky
%
% - Figuring out that we needed to use "AdaptedWhitePoint" in "makecform"
%
% 
% iii. Valuable parts
%
% - Part 3d was a fun challenge, and helped us learn about how "reshape" really
% works in MATLAB
%
% - Practically seeing the differences between calibrated and uncalibrated workflows
%
%
% iv. Improvements
%
% - Minor fixes in the writeup:
%
% - Part 3d: Visualizing the 8 x 12 x 3 array (using image cmd) produces an 
% extremely small image. It helps if we visualize the 768 x 1024 x 3 array instead
%
% - Part 3c: The resulting RGBs from xyz2srgb are not scaled 0-100, but 0-1.
%
% - Parts 1h and 2j: Seem unnecessary since we're not printing them, 
% and they're already being printed by the supplied print functions
%
% - Part 2g: Typo - It should say "workflow_test_cal.ti3" instead of "workflow_test_uncal.ti3"
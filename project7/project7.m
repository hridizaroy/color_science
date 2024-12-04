%% Project 7 Report
% Team 5: Shakira Garnett, Hridiza Roy

cd ../color_toolbox/

%% Initialization
clear all; close all; clc;

% load the CIE observer and illuminant data
cie = loadCIEdata;

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
ground_truth_RGBs_uint8 = munki_RGBs_uint8;  % Random RGB values for ground truth
uncalibrated_RGBs_uint8 = uint8(randi([0, 255], 24, 3));  % Random RGB values for uncalibrated
calibrated_RGBs_uint8 = uint8(randi([0, 255], 24, 3));     % Random RGB values for calibrated

ground_truth_row = zeros([1,12,3])
for i = [1,12]
    ground_truth_row(i) = ground_truth_RGBs_uint8(1,:)    
end


% Visualize the result
figure;
imshow(workflow_diffs);
title('Ground-Truth, Uncalibrated, and Calibrated RGB Values');
axis off;

% Resize the final image to 768x1024 (if needed)
workflow_diffs_resized = imresize(workflow_diffs, [768, 1024], 'nearest');

% Save the resized image as a PNG
imwrite(workflow_diffs_resized, 'workflow_diffs.png');

%% Step 4
% Load the original ColorChecker image
img_orig = imread("chart.jpg");

% Reshape the image into a pixel vector
[r, c, p] = size(img_orig);  % Get the dimensions of the image
pix_orig = reshape(img_orig, [r*c, p])';  % Reshape to 3x(rows*cols)

% Process the pixels through camRGB2XYZ and XYZ2dispRGB
% camRGB2XYZ is assumed to take the RGB values and convert to XYZ
% save the (extended) camera model for use in later projects
save('cam_model.mat', 'cam_polys', 'cam_matrix3x11');
pix_XYZ = camRGB2XYZ('cam_model.mat', pix_orig');  % Convert RGB to XYZ, pix_orig' is 3xN

% XYZ2dispRGB will take the XYZ values and convert to calibrated RGB
pix_DCs_calib = XYZ2dispRGB(pix_XYZ);  % Convert XYZ to color-calibrated RGB

% Reshape the processed pixels back into an image
img_calib = reshape(pix_DCs_calib', [r, c, p]);  % Reshape back to original dimensions

% Save the color-calibrated image as a .png file
imwrite(img_calib, 'color_calibrated_image.png');

% Display the color-calibrated image
imshow(img_calib);
title('Color-Calibrated Image');


cd ../project7/
%% Project 5 Report
% Team 5: Shakira Garnett, Hridiza Roy

%% Initialization
clear all; close all; clc;

% load the CIE observer and illuminant data
cie = loadCIEdata;

%% Step 3
cam_RGBs = [83, 196,  86,  68, 125, 109, 199,  31, 196,  50, 166, 222, 6, 58,...
            166, 237, 186,  11, 219, 188, 152, 102,  44,   5;...
            47,146,112, 87,125,189,104, 55, 68, 13,196,163, 4,126, 20, 204,...
            64,113,218,188,151,102, 46, 8; 28,119,156, 36,177,165, 27, 151,...
            79, 65, 41, 45,113, 43, 29, 47,139,154,213,185,149, 99, 47, 16];

cam_rgbs = cam_RGBs / 255;

cam_gray_rgbs = cam_rgbs(:, 19:24);


%% Step 4

% Load the data
data = load('munki_CC_XYZs_Labs.txt');

% Separate into XYZ and Lab arrays
munki_XYZs = data(:, 2:4)';   % Columns 2-4 for XYZ values, transpose to make it 3x24
munki_Labs = data(:, 5:7)';   % Columns 5-7 for Lab values, transpose to make it 3x24

% Extract Y values for gray patches #19-24
gray_Y_values = munki_XYZs(2, 19:24);

% Normalize the Y values by dividing by 100
normalized_gray_Ys = gray_Y_values / 100;

% Flip the vector so it runs from low (black) to high (white)
munki_gray_Ys = fliplr(normalized_gray_Ys);

%% Step 5

% Plot the Tone Transfer Functions (TTFs)
figure;
hold on;

% Plot each channel (Red, Green, and Blue)
plot(gray_Y_values, cam_gray_rgbs(1, :), '-r'); % Red channel
plot(gray_Y_values, cam_gray_rgbs(2, :), '-g'); % Green channel
plot(gray_Y_values, cam_gray_rgbs(3, :), '-b'); % Blue channel

% Labeling the plot
xlabel('munki gray Ys');
ylabel('camera gray RGBs');
title('original grayscale Y to RGB relationship');
grid on;
hold off;

%% Step 6

% Define indices for color channels
r = 1; g = 2; b = 3;
% a) fit low-order polynomial functions between normalized
% camera-captured gray RGBs and the munki-measured gray Ys
cam_polys(r,:)=polyfit(cam_gray_rgbs(r,:),normalized_gray_Ys,3);
cam_polys(g,:)=polyfit(cam_gray_rgbs(g,:),normalized_gray_Ys,3);
cam_polys(b,:)=polyfit(cam_gray_rgbs(b,:),normalized_gray_Ys,3);
% b) use the functions to linearize the camera data
cam_RSs(r,:) = polyval(cam_polys(r,:),cam_rgbs(r,:));
cam_RSs(g,:) = polyval(cam_polys(g,:),cam_rgbs(g,:));
cam_RSs(b,:) = polyval(cam_polys(b,:),cam_rgbs(b,:));
% c) clip out of range values
cam_RSs(cam_RSs<0) = 0;
cam_RSs(cam_RSs>1) = 1;

%% Step 7

% Extract radiometric scalars for gray patches (#19-24)
gray_RSs = cam_RSs(:, 19:24);

% Plot the TTFs using the radiometric scalars for verification
figure;
hold on;

% Plot each channel's radiometric scalars for gray patches
plot(normalized_gray_Ys, gray_RSs(1, :), '-r'); % Red channel
plot(normalized_gray_Ys, gray_RSs(2, :), '-g'); % Green channel
plot(normalized_gray_Ys, gray_RSs(3, :), '-b'); % Blue channel

% Label the plot for clarity
xlabel('munki gray Ys');
ylabel('linearized camera gray RGBs (RSs)');
title('linearized grayscale Y to RGB relationship');
grid on;
hold off;

%% Step 8

% visualize the original camera RGBs
pix = reshape(cam_rgbs', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90);
pix = flipdim(pix,2);
figure;
image(pix);
title('original camera patch RGBs');

% visualize the linearized camera RGBs
pix = reshape(cam_RSs', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90);
pix = flipdim(pix,2);
figure;
image(pix);
title('linearized camera patch RGBs');

%% Step 9

% use the munki-measured ColorChecker XYZs and camera-captured RGB RSs to
% derive a 3x3 matrix that can be used to estimate XYZs from camera RGBs
cam_matrix3x3 = munki_XYZs * pinv(cam_RSs)

%% Step 10

% estimate the ColorChecker XYZs from the linearized camera rgbs using
% the 3x3 camera matrix
cam_XYZs = cam_matrix3x3 * cam_RSs

%% Step 11

% convert XYZ to Lab
XYZ_D50 = ref2XYZ(cie.PRD, cie.cmf2deg, cie.illD50);
lab_D50_Cam = XYZ2Lab(cam_XYZs, XYZ_D50);

% Calculate deltaEab
DEab_D50 = deltaEab(lab_D50_Cam, munki_Labs);

% print table
print_camera_model_error(munki_Labs, lab_D50_Cam, DEab_D50)

%% Step 12

% split the radiometric scalars (cam_RSs) into r,g,b vectors
RSrgbs = cam_RSs;
RSrs = RSrgbs(1,:);
RSgs = RSrgbs(2,:);
RSbs = RSrgbs(3,:);

% create vectors of these RSs with multiplicative terms to
% represent interactions and square terms to represent non-linearities in
% the RGB-to-XYZ relationship
RSrgbs_extd = [RSrgbs; RSrs.*RSgs; RSrs.*RSbs; RSgs.*RSbs; RSrs.*RSgs.*RSbs; ...
RSrs.^2; RSgs.^2; RSbs.^2; ones(1,size(RSrgbs,2))];

% find the extended (3x11) matrix that relates the RS and XYZ datasets
cam_matrix3x11 = munki_XYZs * pinv(RSrgbs_extd)

%% Step 13

% estimate XYZs from the RSs using the extended matrix and RS representation
cam_XYZs_estimated = cam_matrix3x11 * RSrgbs_extd

%% Step 14

% Calculate XYZ values for cam_XYZs
XYZ_D50 = ref2XYZ(cie.PRD, cie.cmf2deg, cie.illD50);
lab_D50_Cam_estimated = XYZ2Lab(cam_XYZs_estimated, XYZ_D50);

% Calculate deltaEab
DEab = deltaEab(lab_D50_Cam_estimated, munki_Labs);

% Print table
print_extended_camera_model_error(munki_Labs, lab_D50_Cam_estimated, DEab)

%% Step 15

% save the (extended) camera model for use in later projects
save('cam_model.mat', 'cam_polys', 'cam_matrix3x11');

%% Step 16
% Include a listing of the camRGB2XYZ function
%
% <include>camRGB2XYZ.m</include>

% test that the camRGB2XYZ function works correctly
cam_XYZs = camRGB2XYZ('cam_model.mat', cam_RGBs)

%% Step 17
XYZ_D65 = ref2XYZ(cie.PRD, cie.cmf2deg, cie.illD65);

% visualize the munki-measured XYZs as an sRGB image
munki_XYZs_D65 = catBradford(munki_XYZs, XYZ_D50, XYZ_D65);
munki_XYZs_sRGBs = XYZ2sRGB(munki_XYZs_D65);
pix = reshape(munki_XYZs_sRGBs', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90);
pix = flipdim(pix,2);
figure;
image(pix);
title('munki XYZs chromatically adapted and visualized in sRGB');

% visualize the camera-estimated XYZs as an sRGB image
cam_XYZs_D65 = catBradford(cam_XYZs, XYZ_D50, XYZ_D65);
cam_XYZs_sRGBs = XYZ2sRGB(cam_XYZs_D65);
pix = reshape(cam_XYZs_sRGBs', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90);
pix = flipdim(pix,2);
figure;
image(pix);
title('estimated XYZs chromatically adapted and visualized in sRGB');

%% Feedback
% i. Who did which parts
%
% Shakira - parts 2 - 10
%
% Hridiza - parts 1, 11 - 18
%
%
% ii. Problems
%
% - No issues with this project
%
% 
% iii. Valuable parts
%
% - Learning how to compare estimated and measured XYZ values in practice
%
% - Practically seeing how the estimation models work
%
%
% iv. Improvements
%
% - Perhaps there were slightly too many hints for the code for this project
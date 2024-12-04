%% Project 6 Report
% Team 5: Shakira Garnett, Hridiza Roy

%% Initialization
clear all; close all; clc;

% load the CIE observer and illuminant data
cie = loadCIEdata;

%% Step 3
load_ramps_data;

%% Step 4
x_rmax = ramp_R_XYZs(1, 11);
x_gmax = ramp_G_XYZs(1, 11);
x_bmax = ramp_B_XYZs(1, 11);

y_rmax = ramp_R_XYZs(2, 11);
y_gmax = ramp_G_XYZs(2, 11);
y_bmax = ramp_B_XYZs(2, 11);

z_rmax = ramp_R_XYZs(3, 11);
z_gmax = ramp_G_XYZs(3, 11);
z_bmax = ramp_B_XYZs(3, 11);

x_k = XYZk(1);
y_k = XYZk(2);
z_k = XYZk(3);

y_w = XYZw(2);

M_fwd = [ x_rmax - x_k, x_gmax - x_k, x_bmax - x_k, x_k; ...
          y_rmax - y_k, y_gmax - y_k, y_bmax - y_k, y_k; ...
          z_rmax - z_k, z_gmax - z_k, z_bmax - z_k, z_k ] ./ y_w

%% Step 5
M_inv = inv(M_fwd(1:3,1:3));

ramp_R_RSs = M_inv * ( (ramp_R_XYZs - XYZk) / y_w );
ramp_R_RSs = max(min(ramp_R_RSs, 1), 0); % clamp

% define the 0-255 display values (digital counts) that correspond to ramp values
ramp_DCs = round(linspace(0,255,11));

% interpolate the radiometric scalars across the full digital count range to form the forward LUTS
RLUT_fwd = interp1(ramp_DCs,ramp_R_RSs(1,:),[0:1:255],'pchip');

ramp_G_RSs = M_inv * ( (ramp_G_XYZs - XYZk) / y_w );
ramp_G_RSs = max(min(ramp_G_RSs, 1), 0);

% Repeat for green
GLUT_fwd = interp1(ramp_DCs,ramp_G_RSs(2,:), [0:1:255],'pchip');

ramp_B_RSs = M_inv * ( (ramp_B_XYZs - XYZk) / y_w );
ramp_B_RSs = max(min(ramp_B_RSs, 1), 0);

% Repeat for blue
BLUT_fwd = interp1(ramp_DCs,ramp_B_RSs(3,:),[0:1:255],'pchip');

figure;
hold on;

% Plot each channel (Red, Green, and Blue)
plot(0:255, RLUT_fwd, '-r'); % Red channel
plot(0:255, GLUT_fwd, '-g'); % Green channel
plot(0:255, BLUT_fwd, '-b'); % Blue channel

% Labeling the plot
xlabel('digital counts RGB 0-255');
ylabel('radiometric scalars RGB 0-1');
title('forward model LUTs');
grid on;
hold off;

%% Step 6
M_rev = inv(M_fwd(1:3,1:3))

%% Step 7
RLUT_rev = uint8(round(interp1(RLUT_fwd, 0:255, linspace(0,max(RLUT_fwd),1024), 'pchip', 0)));
GLUT_rev = uint8(round(interp1(GLUT_fwd, 0:255, linspace(0,max(GLUT_fwd),1024), 'pchip', 0)));
BLUT_rev = uint8(round(interp1(BLUT_fwd, 0:255, linspace(0,max(BLUT_fwd),1024), 'pchip', 0)));

figure;
hold on;

% Plot each channel (Red, Green, and Blue)
plot(0:1023, RLUT_rev, '-r'); % Red channel
plot(0:1023, GLUT_rev, '-g'); % Green channel
plot(0:1023, BLUT_rev, '-b'); % Blue channel

% Labeling the plot
xlabel('scaled/quantized radiometric scalars RGB 0-1023');
ylabel('digital counts RGB 0-255');
title('reverse model LUTs');
grid on;
hold off;

%% Step 8
XYZw_disp = XYZw;
XYZk_disp = XYZk;
M_disp = M_rev;
RLUT_disp = RLUT_rev;
GLUT_disp = GLUT_rev;
BLUT_disp = BLUT_rev;
save('display_model.mat','XYZw_disp', 'XYZk_disp','M_disp','RLUT_disp','GLUT_disp','BLUT_disp');

%% Step 9

% Load the data
data = load('munki_CC_XYZs_Labs.txt');

XYZn_D50 = ref2XYZ(cie.PRD, cie.cmf2deg, cie.illD50);

munki_XYZs = data(:, 2:4)';   % Columns 2-4 for XYZ values, transpose to make it 3x24
munki_Labs = data(:, 5:7)';   % Columns 5-7 for Lab values, transpose to make it 3x24

munki_XYZs_disp = catBradford(munki_XYZs, XYZn_D50, XYZw_disp);

adjusted_XYZs_disp = munki_XYZs_disp - XYZk_disp;

munki_CC_RSs = (M_disp * adjusted_XYZs_disp) ./ 100;

munki_CC_RSs = max(min(munki_CC_RSs, 1), 0);

munki_CC_RSs_scaled = round(munki_CC_RSs * 1023 + 1);

munki_CC_DCs(1,:) = RLUT_rev(munki_CC_RSs_scaled(1,:));
munki_CC_DCs(2,:) = GLUT_rev(munki_CC_RSs_scaled(2,:));
munki_CC_DCs(3,:) = BLUT_rev(munki_CC_RSs_scaled(3,:));

% visualize the CC XYZs using the display model
pix = uint8(reshape(munki_CC_DCs', [6 4 3]));
pix = fliplr(imrotate(pix, -90));
figure;
image(pix);
set(gca, 'FontSize', 11)
title('colorchecker rendered from measured XYZs using the display model');

%% Step 10
munki_CC_DCs = uint8(double(munki_CC_DCs) * 100/255);
table4ti1 = [(1:30)', [munki_CC_DCs'; zeros(3, 3); 100 * ones(3, 3)] ];

disp_XYZs = importdata('disp_model_test.ti3',' ', 20);

CC_patches_XYZ = disp_XYZs.data(1:24, 5:7);
disp_black_XYZ = disp_XYZs.data(25:27, 5:7);
disp_whiteXYZ = disp_XYZs.data(28:30, 5:7);

XYZk = mean(disp_black_XYZ, 1);
XYZw = mean(disp_whiteXYZ, 1);

display_Labs = XYZ2Lab(CC_patches_XYZ', XYZw');
DEab = deltaEab(display_Labs, munki_Labs);

% print table
print_display_model_error(munki_Labs, display_Labs, DEab);

%% Step 11
% Include a listing of the XYZ2dispRGB function
%
% <include>XYZ2dispRGB.m</include>
disp_RGBs = XYZ2dispRGB('display_model.mat', munki_XYZs, XYZn_D50);

%% Feedback
% i. Who did which parts
%
% Shakira - 3, 4, 5, 6, 7, 8, 9
%
% Hridiza - 1, 2, 5 (minor), 9 (minor), 10, 11, 12
%
%
% ii. Problems
%
% - Keeping the matrix dimensions in mind, and figuring out when to transpose
%
% - Images were getting clipped when trying to publish
%
% 
% iii. Valuable parts
%
% - The "Info only" sections that gave more context about what we were doing
%
% - Learning how to practically derive LUTs and create reverse models
%
%
% iv. Improvements
%
% - Minor: Perhaps we should test that the output from XYZ2dispRGB (disp_RGBs) is as expected
% (Currently we are just testing the plot)
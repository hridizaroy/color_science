%% project 3 report
% Shakira Garnett, Hridiza Roy

%% start clean

clear all; close all; clc;


%% step 2a

% create loadCIEdata (code goes in external file loadCIEdata.m)

% use loadCIEdata
cie = loadCIEdata;


%% step 2b
% include a listing of the indicated function in a published report
% (note that the “include” markup syntax must be part of a
% contiguous comment block that starts with a section marker %%)
%
% <include>loadCIEdata.m</include>


%% step 3
% test loadCIEdata by ploting illA, D50, and D65 vs. the blackbody curves

bb_2856 = blackbody(2856,cie.lambda);

figure;
hold on;

plot(cie.lambda,bb_2856,'k-');

% do this for the rest of the data



%% step 4
% create ref2XYZ in the file ref2XYZ.m
%
% <include>ref2XYZ.m</include>


%% step 5
% test ref2XYZ

CC_spectra = importdata('ColorChecker_380_780_5nm.txt');

for patch_num = 2:25
    CC_XYZs(:,patch_num-1) = ref2XYZ(CC_spectra(:,patch_num),cie.cmf2deg,cie.illD65);
end

% list the XYZs in the report
CC_XYZs


%% step 6
% create XYZ2xyY in the file XYZ2xyY.m


%% step 7
% test XYZ2xyY

CC_xyYs = XYZ2xyY(CC_XYZs)


%% step 8
% load the spectral data for the color patches

% define ColorMunki/Argyll/spotread measurement wavelengths 
cm_lams = 380:10:730;

% load and normalize the measured spectral data for the patch #1
% note: 19 is the number of header lines to skip in the .sp file before
% reading the data. may vary for the real, imaged, and matching .sp files
% so open the files and count down to figure this out

cm_h_offset_im = 18;
cm_h_offset_r = 19;

% load and normalize the measured spectral data for the patch #1
data = importdata('1.1_real.sp', ' ', cm_h_offset_r);
real_11 = data.data/100;
data = importdata('1.1_imaged.sp', ' ', cm_h_offset_im);
imaged_11 = data.data/100;
data = importdata('1.1_matching.sp', ' ', cm_h_offset_im);
matching_11 = data.data/100;

% repeat the section above for patch #2
data = importdata('1.2_real.sp', ' ', cm_h_offset_r);
real_12 = data.data/100;
data = importdata('1.2_imaged.sp', ' ', cm_h_offset_im);
imaged_12 = data.data/100;
data = importdata('1.2_matching.sp', ' ', cm_h_offset_im);
matching_12 = data.data/100;


%% step 9
% interpolate and plot the original and interpolated data

% interpolate/extrapolate the CM spectral data to 380-780, 5nm

% Patch #1
real_11i = interp1(cm_lams, real_11, cie.lambda, 'linear', 'extrap');
imaged_11i = interp1(cm_lams, imaged_11, cie.lambda, 'linear', 'extrap');
matching_11i = interp1(cm_lams, matching_11, cie.lambda, 'linear', 'extrap');

% Patch #2
real_12i = interp1(cm_lams, real_12, cie.lambda, 'linear', 'extrap');
imaged_12i = interp1(cm_lams, imaged_12, cie.lambda, 'linear', 'extrap');
matching_12i = interp1(cm_lams, matching_12, cie.lambda, 'linear', 'extrap');

% create a figure for patch #1 that confirms the process
figure; 
hold on;
line_weight = 1.5;

plot(cm_lams, real_11, 'ro', 'DisplayName', 'real measured');
plot(cm_lams, imaged_11, 'go', 'DisplayName', 'imaged measured');
plot(cm_lams, matching_11, 'bo', 'DisplayName', 'matching measured');

plot(cie.lambda, real_11i, 'r--', 'DisplayName', 'real interpolated');
plot(cie.lambda, imaged_11i, 'g--', 'DisplayName', 'imaged interpolated');
plot(cie.lambda, matching_11i, 'b--', 'DisplayName', 'matching interpolated');

title('Patch 1.1 Measured and Interpolated Spectra');
xlabel('Wavelength (nm)');
ylabel('Reflectance Factor');
legend;
grid on;
xlim([380 780]);

% Figure for patch 2
figure;
hold on;
line_weight = 1.5;

plot(cm_lams, real_12, 'ro', 'DisplayName', 'real measured');
plot(cm_lams, imaged_12, 'go', 'DisplayName', 'imaged measured');
plot(cm_lams, matching_12, 'bo', 'DisplayName', 'matching measured');

plot(cie.lambda, real_12i, 'r--', 'DisplayName', 'real interpolated');
plot(cie.lambda, imaged_12i, 'g--', 'DisplayName', 'imaged interpolated');
plot(cie.lambda, matching_12i, 'b--', 'DisplayName', 'matching interpolated');

title('Patch 1.2 Measured and Interpolated Spectra');
xlabel('Wavelength (nm)');
ylabel('Reflectance Factor');
legend;
grid on;
xlim([380 780]);


%% step 10
% load the measured XYZ data for the patches, calculate XYZs from the
% interpolated spectra and print a table comparing the results

% load and extract the CM measured XYZs
real = importdata('31_CM_XYZs_Labs_real.txt');

XYZmeas.real_311 = real.data(1,2:4)';

% calculate the XYZs from the spectral data
XYZcalc.real_311 = ref2XYZ(real_311i,cie.cmf2deg,cie.illD50);

% do this for the rest of the data


% print formatted tables of measured and calculated XYZs for the color patches





%% step 11
% calculate measured and calculated xyYs and print a table comparing the
% results

% calculate the xyYs from the CM measured XYZs
xyYmeas.real_311 = XYZ2xyY(XYZmeas.real_311);

% do this for the rest of the data


% print formatted tables of measured and calculated xyYs for the color patches



%% step 12
% plot the calculated chromaticity coordinates for the patches on a
% chromaticity diagram

% plot the chromaticity diagram skeleton
plot_chrom_diag_skel;

line_weight = 1.5;


% plot the data for 31.1
x = xyYcalc.real_311(1);
y = xyYcalc.real_311(2);
h(1) = plot(x,y,'rs','LineWidth', line_weight); 

x = xyYcalc.imaged_311(1);
y = xyYcalc.imaged_311(2);
h(2) = plot(x,y,'rd','LineWidth', line_weight); 

% do this for the rest of the data

legend(h, '31.1 real','31.1 imaged', '31.1 matching',...
    '31.2 real','31.2 imaged', '31.2 matching','Location','best');
title('chromaticity coordinates of 31.1 and 31.2 patches');










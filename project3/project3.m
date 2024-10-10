%% Project 3 Report
% Team 5: Shakira Garnett, Hridiza Roy

%% start clean

clear all; close all; clc;


%% step 2a

% load the CIE observer and illuminant data
cie = loadCIEdata;


%% step 2b
% Include listing of loadCIEdata
%
% <include>loadCIEdata.m</include>


%% step 3
% test loadCIEdata by ploting illA, D50, and D65 vs. the blackbody curves

bb_2856 = blackbody(2856,cie.lambda);
bb_5003 = blackbody(5003,cie.lambda);
bb_6504 = blackbody(6504,cie.lambda);

figure(1);
hold on;

plot(cie.lambda,bb_2856,'k', cie.lambda,bb_5003,'r', cie.lambda,bb_6504,'b', ...
    cie.lambda,(cie.illA / 100),'--k',  cie.lambda,(cie.illD50 / 100),'--r', ...
    cie.lambda,(cie.illD65 / 100),'--b');
legend('blackbody (2856K)', 'blackbody (5003K)', 'blackbody (6504K)', ...
    'illuminant A', 'illuminant D50', 'illuminant D65', 'Location','best');
title('blackbody and standard illuminant spectra');
xlabel('wavelength(nm)'); 
ylabel('relative power'); 

figure(2);
hold on;

plot(cie.lambda,cie.cmf2deg(:,1,:),'r', cie.lambda,cie.cmf2deg(:,2,:),'g', ...
    cie.lambda,cie.cmf2deg(:,3,:),'b',  cie.lambda,cie.cmf10deg(:,1,:),'--r',...
    cie.lambda,cie.cmf10deg(:,2,:),'--g',  cie.lambda,cie.cmf10deg(:,3,:),'--b');
legend('x_b_a_r 2 deg', 'y_b_a_r 2 deg', 'z_b_a_r 2 deg', 'x_b_a_r 10 deg', ...
    'y_b_a_r 10 deg', 'z_b_a_r 10 deg', 'Location','best');
title('CIE standard observer CMFs');
xlabel('wavelength(nm)'); 
ylabel('tristimulus values'); 
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

CC_XYZs


%% step 6
% create XYZ2xyY in the file XYZ2xyY.m
%%
% <include>XYZ2xyY.m</include>

%% step 7
% test XYZ2xyY

CC_xyYs = XYZ2xyY(CC_XYZs)


%% step 8
% load the spectral data for the color patches

% define ColorMunki/Argyll/spotread measurement wavelengths 
cm_lams = 380:10:730;

cm_h_offset_im = 18;
cm_h_offset_r = 19;

% load and normalize the measured spectral data for the patch #1
data = importdata('1.1_real.sp', ' ', cm_h_offset_r);
real_11 = data.data/100;
data = importdata('1.1_imaged.sp', ' ', cm_h_offset_im);
imaged_11 = data.data/100;
data = importdata('1.1_matching.sp', ' ', cm_h_offset_im);
matching_11 = data.data/100;

% repeat for patch #2
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

plot(cm_lams, real_11, 'ro', 'DisplayName', 'real measured');
plot(cm_lams, imaged_11, 'go', 'DisplayName', 'imaged measured');
plot(cm_lams, matching_11, 'bo', 'DisplayName', 'matching measured');

plot(cie.lambda, real_11i, 'r--', 'DisplayName', 'real interpolated');
plot(cie.lambda, imaged_11i, 'g--', 'DisplayName', 'imaged interpolated');
plot(cie.lambda, matching_11i, 'b--', 'DisplayName', 'matching interpolated');

title('Patch 1.1 Measured and Interpolated Spectra');
xlabel('Wavelength (nm)');
ylabel('Reflectance Factor');
legend('Location', 'best');;
grid on;
xlim([380 780]);
ylim([0 1]);

% Figure for patch 2
figure;
hold on;

plot(cm_lams, real_12, 'ro', 'DisplayName', 'real measured');
plot(cm_lams, imaged_12, 'go', 'DisplayName', 'imaged measured');
plot(cm_lams, matching_12, 'bo', 'DisplayName', 'matching measured');

plot(cie.lambda, real_12i, 'r--', 'DisplayName', 'real interpolated');
plot(cie.lambda, imaged_12i, 'g--', 'DisplayName', 'imaged interpolated');
plot(cie.lambda, matching_12i, 'b--', 'DisplayName', 'matching interpolated');

title('Patch 1.2 Measured and Interpolated Spectra');
xlabel('Wavelength (nm)');
ylabel('Reflectance Factor');
legend('Location', 'best');
grid on;
xlim([380 780]);
ylim([0 1]);


%% step 10
% load the measured XYZ data for the patches, calculate XYZs from the
% interpolated spectra and print a table comparing the results

% load and extract the CM measured XYZs
real = importdata('1_XYZ_Labs_real.txt');
imaged = importdata('1_XYZ_Labs_imaged.txt');
matching = importdata('1_XYZ_Labs_matching.txt');

XYZmeas.real_11 = real.data(1,2:4)';
XYZmeas.imaged_11 = imaged.data(1,2:4)';
XYZmeas.matching_11 = matching.data(1,2:4)';

XYZmeas.real_12 = real.data(2,2:4)';
XYZmeas.imaged_12 = imaged.data(2,2:4)';
XYZmeas.matching_12 = matching.data(2,2:4)';

% calculate the XYZs from the spectral data
XYZcalc.real_11 = ref2XYZ(real_11i,cie.cmf2deg,cie.illD50);
XYZcalc.imaged_11 = ref2XYZ(imaged_11i,cie.cmf2deg,cie.illD50);
XYZcalc.matching_11 = ref2XYZ(matching_11i,cie.cmf2deg,cie.illD50);

XYZcalc.real_12 = ref2XYZ(real_12i,cie.cmf2deg,cie.illD50);
XYZcalc.imaged_12 = ref2XYZ(imaged_12i,cie.cmf2deg,cie.illD50);
XYZcalc.matching_12 = ref2XYZ(matching_12i,cie.cmf2deg,cie.illD50);


% print formatted tables of measured and calculated XYZs for the color patches
fprintf('Measured and calculated tristimulus values\n\n');
fprintf('\t\t\t patch 1.1\n');
fprintf('\t\tmeasured\t\tcalculated\n');
fprintf('\t      X\t\tY\tZ\tX\tY\t  Z\n');
fprintf('%8s% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f\n', 'real', ...
    XYZmeas.real_11', XYZcalc.real_11');
fprintf('%8s% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f\n', 'imaged', ...
    XYZmeas.imaged_11', XYZcalc.imaged_11');
fprintf('%8s% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f\n', 'matching', ...
    XYZmeas.matching_11', XYZcalc.matching_11');

fprintf('\n\n');
fprintf('\t\t\t patch 1.2\n');
fprintf('\t\tmeasured\t\tcalculated\n');
fprintf('\t      X\t\tY\tZ\tX\tY\t  Z\n');
fprintf('%8s% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f\n', 'real', ...
    XYZmeas.real_12', XYZcalc.real_12');
fprintf('%8s% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f\n', 'imaged', ...
    XYZmeas.imaged_12', XYZcalc.imaged_12');
fprintf('%8s% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f\n', 'matching', ...
    XYZmeas.matching_12', XYZcalc.matching_12');








%% step 11
% calculate measured and calculated xyYs and print a table comparing the
% results

% calculate the xyYs from the CM measured XYZs
xyYmeas.real_11 = XYZ2xyY(XYZmeas.real_11);
xyYmeas.imaged_11 = XYZ2xyY(XYZmeas.imaged_11);
xyYmeas.matching_11 = XYZ2xyY(XYZmeas.matching_11);

xyYmeas.real_12 = XYZ2xyY(XYZmeas.real_12);
xyYmeas.imaged_12 = XYZ2xyY(XYZmeas.imaged_12);
xyYmeas.matching_12 = XYZ2xyY(XYZmeas.matching_12);

xyYcalc.real_11 = XYZ2xyY(XYZcalc.real_11);
xyYcalc.imaged_11 = XYZ2xyY(XYZcalc.imaged_11);
xyYcalc.matching_11 = XYZ2xyY(XYZcalc.matching_11);

xyYcalc.real_12 = XYZ2xyY(XYZcalc.real_12);
xyYcalc.imaged_12 = XYZ2xyY(XYZcalc.imaged_12);
xyYcalc.matching_12 = XYZ2xyY(XYZcalc.matching_12);


% print formatted tables of measured and calculated xyYs for the color patches
fprintf('\n\nMeasured and calculated chromaticity coordinates\n\n');
fprintf('\t\t\t patch 1.1\n');
fprintf('\t\tmeasured\t\tcalculated\n');
fprintf('\t      x\t\ty\tY\tx\ty\t  Y\n');
fprintf('%8s% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f\n', 'real', ...
    xyYmeas.real_11', xyYcalc.real_11');
fprintf('%8s% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f\n', 'imaged', ...
    xyYmeas.imaged_11', xyYcalc.imaged_11');
fprintf('%8s% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f\n', 'matching', ...
    xyYmeas.matching_11', xyYcalc.matching_11');

fprintf('\n\n');
fprintf('\t\t\t patch 1.2\n');
fprintf('\t\tmeasured\t\tcalculated\n');
fprintf('\t      x\t\ty\tY\tx\ty\t  Y\n');
fprintf('%8s% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f\n', 'real', ...
    xyYmeas.real_12', xyYcalc.real_12');
fprintf('%8s% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f\n', 'imaged', ...
    xyYmeas.imaged_12', xyYcalc.imaged_12');
fprintf('%8s% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f\n', 'matching', ...
    xyYmeas.matching_12', xyYcalc.matching_12');



%% step 12
% plot the calculated chromaticity coordinates for the patches on a
% chromaticity diagram

% plot the chromaticity diagram skeleton
plot_chrom_diag_skel;

line_weight = 1.0;


% plot the data for 1.1
x = xyYcalc.real_11(1);
y = xyYcalc.real_11(2);
h(1) = plot(x,y,'rs','LineWidth', line_weight); 

x = xyYcalc.imaged_11(1);
y = xyYcalc.imaged_11(2);
h(2) = plot(x,y,'rd','LineWidth', line_weight); 

x = xyYcalc.matching_11(1);
y = xyYcalc.matching_11(2);
h(3) = plot(x,y,'r+','LineWidth', line_weight); 


% plot the data for 1.2
x = xyYcalc.real_12(1);
y = xyYcalc.real_12(2);
h(4) = plot(x,y,'bs','LineWidth', line_weight); 

x = xyYcalc.imaged_12(1);
y = xyYcalc.imaged_12(2);
h(5) = plot(x,y,'bd','LineWidth', line_weight); 

x = xyYcalc.matching_12(1);
y = xyYcalc.matching_12(2);
h(6) = plot(x,y,'b+','LineWidth', line_weight); 

legend(h, '1.1 real','1.1 imaged', '1.1 matching',...
    '1.2 real','1.2 imaged', '1.2 matching','Location','best');
title('chromaticity coordinates of 1.1 and 1.2 patches');



%% feedback
% i. Who did which parts
%
% Shakira - parts 2, 3, 6, 7, 10
%
% Hridiza - parts 4, 5, 8, 9, 11, 12, 13
%
%
% ii. Problems
%
% - The chromaticity plot has values that are very close together, which is making them hard to discern
%
% - Formatting the tables was challenging
%
% 
% iii. Valuable parts
%
% - Learning how to interpret and use the measured data to gain insights
%
%
% iv. Improvements
%
% - A section asking us to interpret the chromaticity coordinates might be beneficial







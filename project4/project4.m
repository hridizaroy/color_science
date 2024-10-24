%% Project 4 Report
% Team 5: Shakira Garnett, Hridiza Roy

%% Initialization
clear all; close all; clc;

% load the CIE observer and illuminant data
cie = loadCIEdata;

%% Step 2
% Include a listing of the ref2XYZ function
%
% <include>ref2XYZ.m</include>

%% Step 3
% Test ref2XYZ function
CC_spectra = load('ColorChecker_380-780-5nm.txt');
CC_XYZs = ref2XYZ(CC_spectra(:, 2:25), cie.cmf2deg, cie.illD65)

%% Step 4
% Create XYZ2Lab function
%
% <include>XYZ2Lab.m</include>

%% Step 6
% Test XYZ2Lab function

% compute the XYZ values for XYZ in XYZ2Lab
CC_spectra = load('ColorChecker_380-780-5nm.txt');
CC_XYZs = ref2XYZ(0.02 * CC_spectra(:,2:25),cie.cmf2deg,cie.illD65);

% compute the XYZ values of D65 for XYZn in XYZ2Lab
XYZn_D65 = ref2XYZ(cie.PRD,cie.cmf2deg,cie.illD65);

% calculate the Lab values
CC_Labs = XYZ2Lab(CC_XYZs, XYZn_D65);

% read in the names of the ColorChecker patches
names = textread('ColorChecker_names.txt','%s','delimiter','|');

% print the formatted table
% header
fprintf("\nColorChecker XYZ and Lab values (D65 illuminant and 2 deg. observer)\n\n");
fprintf("Patch #\t   X\t  Y\t  Z\t  L*\t  a*\t  b*\t Patch Name\n");

% loop to print the patch values
for i=1:size(CC_Labs,2)
    fprintf("%7d\t %6.3f\t%6.3f\t%6.3f\t%6.3f\t%6.3f\t%6.3f\t %s\n", i, ...
        CC_XYZs(1, i), CC_XYZs(2, i), CC_XYZs(3, i), CC_Labs(1, i), ...
        CC_Labs(2, i), CC_Labs(3, i), names{i});
end

%% Step 7
% Create deltaEab function
%
% <include>deltaEab.m</include>

%% Step 8
% Test deltaEab function
MC_spectra = load('MetaChecker_380-780-5nm.txt');

% compute the XYZ values of D65 and illuminant A
XYZ_D65 = ref2XYZ(cie.PRD, cie.cmf2deg, cie.illD65);
XYZ_illA = ref2XYZ(cie.PRD, cie.cmf2deg, cie.illA);

% compute XYZ values for ColorChecker and MetaChecker under D65
XYZ_D65_CC = ref2XYZ(CC_spectra, cie.cmf2deg, cie.illD65);
XYZ_D65_MC = ref2XYZ(MC_spectra, cie.cmf2deg, cie.illD65);

% compute XYZ values for ColorChecker and MetaChecker under illuminant A
XYZ_A_CC= ref2XYZ(CC_spectra, cie.cmf2deg, cie.illA);
XYZ_A_MC = ref2XYZ(MC_spectra, cie.cmf2deg, cie.illA);

% convert XYZ to Lab
lab_D65_CC = XYZ2Lab(XYZ_D65_CC, XYZ_D65);
lab_D65_MC = XYZ2Lab(XYZ_D65_MC, XYZ_D65);

lab_A_CC = XYZ2Lab(XYZ_A_CC, XYZ_illA);
lab_A_MC = XYZ2Lab(XYZ_A_MC, XYZ_illA);

% Calculate deltaEab for D65
DEab_D65 = deltaEab(lab_D65_CC, lab_D65_MC);

% Calculate deltaEab for illuminant A
DEab_A = deltaEab(lab_A_CC, lab_A_MC);

% Display results
numPatches = size(DEab_D65, 2);

fprintf("\nColorChecker and MetaChecker color differences\n\n")
fprintf("  patch #    DEab(D65)    DEab(illA)\n");

for i = 1+1:numPatches
    fprintf("%9d   %10.3e%10.3f\n", i-1, DEab_D65(i), DEab_A(i));
end

%% Step 9
% Calculate CIELab values and color differences for real, imaged and matching color patches

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

% interpolate/extrapolate the CM spectral data to 380-780, 5nm
% Patch #1
real_11i = interp1(cm_lams, real_11, cie.lambda, 'linear', 'extrap');
imaged_11i = interp1(cm_lams, imaged_11, cie.lambda, 'linear', 'extrap');
matching_11i = interp1(cm_lams, matching_11, cie.lambda, 'linear', 'extrap');

% Patch #2
real_12i = interp1(cm_lams, real_12, cie.lambda, 'linear', 'extrap');
imaged_12i = interp1(cm_lams, imaged_12, cie.lambda, 'linear', 'extrap');
matching_12i = interp1(cm_lams, matching_12, cie.lambda, 'linear', 'extrap');

% Calculated XYZs
XYZcalc.real_11 = ref2XYZ(real_11i, cie.cmf2deg, cie.illD50);
XYZcalc.imaged_11 = ref2XYZ(imaged_11i, cie.cmf2deg, cie.illD50);
XYZcalc.matching_11 = ref2XYZ(matching_11i, cie.cmf2deg, cie.illD50);

XYZcalc.real_12 = ref2XYZ(real_12i, cie.cmf2deg, cie.illD50);
XYZcalc.imaged_12 = ref2XYZ(imaged_12i, cie.cmf2deg, cie.illD50);
XYZcalc.matching_12 = ref2XYZ(matching_12i, cie.cmf2deg, cie.illD50);

XYZn_D50 = ref2XYZ(cie.PRD, cie.cmf2deg, cie.illD50);

% Calculate LAB values

% Patch 1
lab_real_11 = XYZ2Lab(XYZcalc.real_11, XYZn_D50);
lab_imaged_11 = XYZ2Lab(XYZcalc.imaged_11, XYZn_D50);
lab_matching_11 = XYZ2Lab(XYZcalc.matching_11, XYZn_D50);

% Patch 2
lab_real_12 = XYZ2Lab(XYZcalc.real_12, XYZn_D50);
lab_imaged_12 = XYZ2Lab(XYZcalc.imaged_12, XYZn_D50);
lab_matching_12 = XYZ2Lab(XYZcalc.matching_12, XYZn_D50);

% Calculate deltaEab
% For patch 1
DEab_real_imaged_11 = deltaEab(lab_real_11, lab_imaged_11);
DEab_real_matching_11 = deltaEab(lab_real_11, lab_matching_11);

% For patch 2
DEab_real_imaged_12 = deltaEab(lab_real_12, lab_imaged_12);
DEab_real_matching_12 = deltaEab(lab_real_12, lab_matching_12);

% Display table
fprintf('\nCalculated XYZ, Lab, and deltaE values (w.r.t. real patches)\n\n');
fprintf('                                 patch 1.1\n');
fprintf('              X          Y          Z          L          a          b        dEab\n');
fprintf('    real %9.4f  %9.4f  %9.4f  %9.4f  %9.4f  %9.4f\n', ...
    XYZcalc.real_11(1), XYZcalc.real_11(2), XYZcalc.real_11(3), ...
    lab_real_11(1), lab_real_11(2), lab_real_11(3));
fprintf('  imaged %9.4f  %9.4f  %9.4f  %9.4f  %9.4f  %9.4f  %9.4f\n', ...
    XYZcalc.imaged_11(1), XYZcalc.imaged_11(2), XYZcalc.imaged_11(3), ...
    lab_imaged_11(1), lab_imaged_11(2), lab_imaged_11(3), DEab_real_imaged_11);
fprintf('matching %9.4f  %9.4f  %9.4f  %9.4f  %9.4f  %9.4f  %9.4f\n', ...
    XYZcalc.matching_11(1), XYZcalc.matching_11(2), XYZcalc.matching_11(3), ...
    lab_matching_11(1), lab_matching_11(2), lab_matching_11(3), DEab_real_matching_11);

fprintf('\n');
fprintf('                                 patch 1.2\n');
fprintf('              X          Y          Z          L          a          b        dEab\n');
fprintf('    real %9.4f  %9.4f  %9.4f  %9.4f  %9.4f  %9.4f\n', ...
    XYZcalc.real_12(1), XYZcalc.real_12(2), XYZcalc.real_12(3), ...
    lab_real_12(1), lab_real_12(2), lab_real_12(3));
fprintf('  imaged %9.4f  %9.4f  %9.4f  %9.4f  %9.4f  %9.4f  %9.4f\n', ...
    XYZcalc.imaged_12(1), XYZcalc.imaged_12(2), XYZcalc.imaged_12(3), ...
    lab_imaged_12(1), lab_imaged_12(2), lab_imaged_12(3), DEab_real_imaged_12);
fprintf('matching %9.4f  %9.4f  %9.4f  %9.4f  %9.4f  %9.4f  %9.4f\n', ...
    XYZcalc.matching_12(1), XYZcalc.matching_12(2), XYZcalc.matching_12(3), ...
    lab_matching_12(1), lab_matching_12(2), lab_matching_12(3), DEab_real_matching_12);


%% Step 10
% Visualize the color differences between real, imaged, and matching patches

% Create the plot for a* and b* values
figure;
hold on;

% Plot for Patch 1.1
plot(lab_real_11(2), lab_real_11(3), 'bo', 'MarkerFaceColor', 'b', 'DisplayName', '1.1 real');
plot(lab_imaged_11(2), lab_imaged_11(3), 'bs', 'MarkerFaceColor', 'b', 'DisplayName', '1.1 imaged');
plot(lab_matching_11(2), lab_matching_11(3), 'bd', 'MarkerFaceColor', 'b', 'DisplayName', '1.1 matching');

% Plot for Patch 1.2
plot(lab_real_12(2), lab_real_12(3), 'ro', 'MarkerFaceColor', 'r', 'DisplayName', '1.2 real');
plot(lab_imaged_12(2), lab_imaged_12(3), 'rs', 'MarkerFaceColor', 'r', 'DisplayName', '1.2 imaged');
plot(lab_matching_12(2), lab_matching_12(3), 'rd', 'MarkerFaceColor', 'r', 'DisplayName', '1.2 matching');

% Add circles with radius 2.5 around the real patches
viscircles([lab_real_11(2), lab_real_11(3)], 2.5, 'EdgeColor', 'black', 'LineWidth', 0.5);
viscircles([lab_real_12(2), lab_real_12(3)], 2.5, 'EdgeColor', 'black', 'LineWidth', 0.5);

% Set axis limits and make the plot square
xlim([-60 60]);
ylim([-60 60]);
axis('square');

grid on;

xticks(min(xlim):10:max(xlim));
yticks(min(ylim):10:max(ylim));

% Label axes
xlabel('a*');
ylabel('b*');

% Add legend
legend('show');

hold off;

%% Feedback
% i. Who did which parts
%
% Shakira - parts 2, 3, 4, 5, 6
%
% Hridiza - parts 7, 8, 9, 10, 11
%
%
% ii. Problems
%
% - Formatting the tables
%
% 
% iii. Valuable parts
%
% - Understanding what deltaEab represents
%
% - Getting practice with functions and matrix operations in MATLAB
%
%
% iv. Improvements
%
% - More hints on formatting
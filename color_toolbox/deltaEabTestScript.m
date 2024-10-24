% load the CIE data into a structure
cie = loadCIEdata;

CC_spectra = load('ColorChecker_380-780-5nm.txt');
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

fprintf("ColorChecker and MetaChecker color differences\n")
fprintf("  patch #    DEab(D65)    DEab(illA)\n");

for i = 1+1:numPatches
    fprintf("%9d   %10.3e%10.3f\n", i-1, DEab_D65(i), DEab_A(i));
end
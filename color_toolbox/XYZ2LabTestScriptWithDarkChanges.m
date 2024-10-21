% load the CIE data into a structure
cie = loadCIEdata;

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
fprintf("ColorCecker XYZ and Lab values (D65 illuminant and 2 deg. observer)\n\n");
fprintf("Patch\t#\t  X\t  Y\t  Z\t  L*\t  a*\t  b*\t Patch Name\n");

% loop to print the patch values
for i=1:size(CC_Labs,2)
    fprintf("\t%d\t%6.3f\t%6.3f\t%6.3f\t%6.3f\t%6.3f\t%6.3f\t %s\n", i, CC_XYZs(1, i), CC_XYZs(2, i), CC_XYZs(3, i), CC_Labs(1, i), CC_Labs(2, i), CC_Labs(3, i), names{i});
end

function [cie] = loadCIEdata
    data2deg = load('../color_toolbox/CIE_2Deg_380-780-5nm.txt');
    cie.lambda = data2deg(:, 1);        % Wavelengths (81x1 column vector)
    cie.cmf2deg = data2deg(:, 2:4);     % 2-degree CMF (81x3 array)

    data10deg = load('../color_toolbox/CIE_10Deg_380-780-5nm.txt');
    cie.cmf10deg = data10deg(:, 2:4);   % 10-degree CMF (81x3 array)

    dataIllA = load('../color_toolbox/CIE_IllA_380-780-5nm.txt');
    cie.illA = dataIllA(:, 2);          % Illuminant A (81x1 column vector)

    dataIllC = load('../color_toolbox/CIE_IllC_380-780-5nm.txt');
    cie.illC = dataIllC(:, 2);          % Illuminant C (81x1 column vector)

    dataIllD50 = load('../color_toolbox/CIE_IllD50_380-780-5nm.txt');
    cie.illD50 = dataIllD50(:, 2);      % Illuminant D50 (81x1 column vector)

    dataIllD65 = load('../color_toolbox/CIE_IllD65_380-780-5nm.txt');
    cie.illD65 = dataIllD65(:, 2);      % Illuminant D65 (81x1 column vector)

    % Create illuminant E with a constant value of 100
    cie.illE = 100 * ones(81, 1);       % Illuminant E (81x1 column vector)

    dataIllF = load('../color_toolbox/CIE_IllF_1-12_380-780-5nm.txt');
    cie.illF = dataIllF(:, 2:end);      % Illuminant F1-F12 (81x12 array)

    % Create PRD with a constant value of 1
    cie.PRD = ones(81, 1);              % PRD (81x1 column vector)
end
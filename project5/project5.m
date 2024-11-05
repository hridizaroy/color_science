% code for question 3
cam_RGBs = [83, 196,  86,  68, 125, 109, 199,  31, 196,  50, 166, 222,   6,  58, 166, 237, 186,  11, 219, 188, 152, 102,  44,   5;...
    47,146,112, 87,125,189,104, 55, 68, 13,196,163,  4,126, 20,204, 64,113,218,188,151,102, 46,  8;...
    28,119,156, 36,177,165, 27,151, 79, 65, 41, 45,113, 43, 29, 47,139,154,213,185,149, 99, 47, 16];

cam_rgbs = cam_RGBs / 255;

cam_gray_rgbs = cam_rgbs(:, 19:24);


% code for question 4
% Load the data
data = load('../color_toolbox/munki_CC_XYZs_Labs.txt');

% Separate into XYZ and Lab arrays
munki_XYZs = data(:, 2:4)';   % Columns 2-4 for XYZ values, transpose to make it 3x24
munki_Labs = data(:, 5:7)';   % Columns 5-7 for Lab values, transpose to make it 3x24

% Extract Y values for gray patches #19-24
gray_Y_values = munki_XYZs(2, 19:24);

% Normalize the Y values by dividing by 100
normalized_gray_Ys = gray_Y_values / 100;

% Flip the vector so it runs from low (black) to high (white)
munki_gray_Ys = fliplr(normalized_gray_Ys);

% code for question 5
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

% code for question 6
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

% code for question 7
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

% code for question 8
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

% code for question 9
% use the munki-measured ColorChecker XYZs and camera-captured RGB RSs to
% derive a 3x3 matrix that can be used to estimate XYZs from camera RGBs
cam_matrix3x3 = munki_XYZs * pinv(cam_RSs);

% resulting matrix needed for report 
% cam_matrix3x3 =

%    42.1733   25.5418   22.5755
%    20.8446   56.9833   16.4482
%    -1.4126    3.9189   77.4845

% code for question 10
% estimate the ColorChecker XYZs from the linearized camera rgbs using
% the 3x3 camera matrix
cam_XYZs = cam_matrix3x3 * cam_RSs;

% resulting matrix needed for report
% cam_XYZs =

%     9.9881   40.6913   20.2649   10.9455   28.1071   33.2503   34.4405   13.9377   33.8050    8.1306   36.5103   51.2355    6.5105   13.0420   20.6221   62.9629   33.5519   15.3683   79.5116   52.4961   31.3031   16.4578    8.5953    2.4104
%     9.5310   35.6141   21.1540   12.6487   27.3932   44.9620   25.6034   13.5392   23.0515    6.3807   47.4240   43.9657    5.0990   17.8175   12.8482   63.9356   23.4835   18.7891   82.9864   54.9025   32.6103   17.1957    8.9872    2.5133
%     4.6532   18.1834   30.0899    6.3029   40.8227   35.6976    4.0742   27.7568   11.0148    9.7830    8.6113    7.5458   16.6086    7.7552    4.2740    8.9579   22.8486   29.4141   70.3343   46.7538   27.5271   14.6003    7.7570    2.0393

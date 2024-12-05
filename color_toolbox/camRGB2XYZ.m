function cam_XYZs = camRGB2XYZ(cam_model, cam_RGBs)

    % Load cam_polys and cam_matrix3x11 from the cam_model file
    load(cam_model, 'cam_polys', 'cam_matrix3x11');

    % Normalize cam_RGBs to the range 0-1
    cam_rgbs = double(cam_RGBs) / 255;

    % Define indices for color channels
    r = 1; g = 2; b = 3;

    % linearize the camera data
    cam_RSs(r,:) = polyval(cam_polys(r,:), cam_rgbs(r,:));
    cam_RSs(g,:) = polyval(cam_polys(g,:), cam_rgbs(g,:));
    cam_RSs(b,:) = polyval(cam_polys(b,:), cam_rgbs(b,:));
    
    % clip out of range values
    cam_RSs(cam_RSs<0) = 0;
    cam_RSs(cam_RSs>1) = 1;

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

    % Return estimated XYZ values
    cam_XYZs = cam_matrix3x11 * RSrgbs_extd;

end
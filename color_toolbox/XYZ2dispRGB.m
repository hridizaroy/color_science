function disp_RGBs = XYZ2dispRGB(display_model, XYZs, XYZn)
    load(display_model, 'XYZw_disp', 'XYZk_disp','M_disp','RLUT_disp','GLUT_disp','BLUT_disp');
    
    XYZs_disp = catBradford(XYZs, XYZn, XYZw_disp);

    adjusted_XYZs_disp = XYZs_disp - XYZk_disp;
    
    CC_RSs = (M_disp * adjusted_XYZs_disp) ./ 100;
    
    CC_RSs = max(0, min(1, CC_RSs));
    
    CC_RSs_scaled = round(CC_RSs * 1023 + 1);
    
    CC_DCs(1,:) = RLUT_disp(CC_RSs_scaled(1,:));
    CC_DCs(2,:) = GLUT_disp(CC_RSs_scaled(2,:));
    CC_DCs(3,:) = BLUT_disp(CC_RSs_scaled(3,:));

    
    % % visualize the CC XYZs using the display model
    % pix = uint8(reshape(CC_DCs', [6 4 3]));
    % pix = fliplr(imrotate(pix, -90));
    % figure;
    % image(pix);
    % set(gca, 'FontSize', 10.5);
    % title('colorchecker rendered from measured XYZs using XYZ2dispRGB function');

    disp_RGBs = uint8(CC_DCs);
end
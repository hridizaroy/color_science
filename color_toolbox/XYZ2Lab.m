function Lab = XYZ2Lab(XYZ, XYZn)

    % Split the matrix into corresponding row vectors
    X = XYZ(1,:,:);
    Y = XYZ(2,:,:);
    Z = XYZ(3,:,:);
    X_n = XYZn(1,:,:);
    Y_n = XYZn(2,:,:);
    Z_n = XYZn(3,:,:);

    % calculate chromaticitity coords
    Y_ratio = Y ./ Y_n;
    L = 116 * ((Y_ratio > 0.008856) .* Y_ratio.^(1/3) + (Y_ratio <= 0.008856) ...
        .* (7.787 * Y_ratio + (16/116))) - 16;

    % a calculation
    X_ratio = X ./ X_n;
    a = 500 * (((X_ratio > 0.008856) .* X_ratio.^(1/3) + (X_ratio <= 0.008856) ...
        .* (7.787 * X_ratio)) - ((Y_ratio > 0.008856) .* Y_ratio.^(1/3) + ...
        (Y_ratio <= 0.008856) .* (7.787 * Y_ratio)));

    % b calculation
    Z_ratio = Z ./ Z_n;
    b = 200 * (((Y_ratio > 0.008856) .* Y_ratio.^(1/3) + (Y_ratio <= 0.008856) ...
        .* (7.787 * Y_ratio)) - ((Z_ratio > 0.008856) .* Z_ratio.^(1/3) + ...
        (Z_ratio <= 0.008856) .* (7.787 * Z_ratio)));

    % reconstruct & return LAB matrix
    Lab = [L;a;b];

end

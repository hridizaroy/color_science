%%
% <include>XYZ2xyY.m</include>
function xyY = XYZ2xyY(XYZ)

    % Split the matrix into corresponding row vectors
    X = XYZ(1,:,:);
    Y = XYZ(2,:,:);
    Z = XYZ(3,:,:);

    % calculate chromaticitity coords
    x = X ./ (X + Y + Z);
    y = Y ./ (X + Y + Z);

    % reconstruct & return xyY matrix
    xyY = [x;y;Y];

end

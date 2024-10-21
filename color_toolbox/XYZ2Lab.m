function Lab = XYZ2Lab(XYZ, XYZn)

    % Split the matrix into corresponding row vectors
    X = XYZ(1,:,:);
    Y = XYZ(2,:,:);
    Z = XYZ(3,:,:);
    X_n = XYZn(1,:,:);
    Y_n = XYZn(2,:,:);
    Z_n = XYZn(3,:,:);

    % calculate chromaticitity coords
    L = 116 * f(Y ./ Y_n) - 16;
    a = 500 * (f(X ./ X_n) - f(Y ./ Y_n));
    b = 200 * (f(Y ./ Y_n) - f(Z ./ Z_n));

    % reconstruct & return xyY matrix
    Lab = [L;a;b];

end

function helper_out = f(inputVector)
    % This function takes a 1xn row vector and transforms it
    % If an element is greater than 0.008856, it replaces the value with its cube root
    % Otherwise, it replaces the value with 7.787 * value + 16/116
    
    % Initialize the helper_out vector with the same size as input
    helper_out = zeros(size(inputVector));
    
    % Iterate through each element in the input vector
    for i = 1:length(inputVector)
        if inputVector(i) > 0.008856
            helper_out(i) = inputVector(i)^(1/3);
        else
            helper_out(i) = 7.787 * inputVector(i) + (16/116);  
        end
    end
end

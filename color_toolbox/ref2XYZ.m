function XYZ = ref2XYZ(ref,cmfs,ill);
% simple version of ref2XYZ that doesn't use matrix mults

%compute normalizing constant for the illuminant
k = 100./sum(cmfs(:,2).*ill);

%compute the XYZs
X = k.*sum(cmfs(:,1).*ill.*ref);
Y = k.*sum(cmfs(:,2).*ill.*ref);
Z = k.*sum(cmfs(:,3).*ill.*ref);

% return them in a 3xn array
XYZ = [X;Y;Z];

end

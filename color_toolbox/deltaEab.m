function DEab = deltaEab(Lab1, Lab2)
    DEab = sqrt(sum((Lab2 - Lab1) .^ 2));
end
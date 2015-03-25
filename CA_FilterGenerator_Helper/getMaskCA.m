function CAMask = getMaskCA(rule_number)
%%%
% rule_number - the Linear CA rule number
% CAMask - the Moore Neighborhood represtation of the CA rule number
if rule_number>511
    rule_number=250;
end
% get the binary representation
baz = num2matrix(dec2bin(rule_number));
baz = [zeros(1,9-length(baz)) baz ]; 
baz = flip(baz); %flip to get the binary in the correct direction for placement in the mask
CAMask = [baz(7),baz(8),baz(9);baz(6),baz(1),baz(2);baz(5),baz(4),baz(3)];
end

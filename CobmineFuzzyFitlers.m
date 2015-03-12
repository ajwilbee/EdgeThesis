%combine Fizzy results from Train and Test runs into a single set
AllFiltersTrain(cellfun(@isempty,AllFiltersTrain)) = [];
AllFilters(cellfun(@isempty,AllFilters)) = [];

AllFilters = [AllFiltersTrain ; AllFilters];

for x = 1:size(AllImages,1)
    for y = 1: size(AllImages{x,3},1)
        AllImages{x,3}(y,1) = AllImages{x,3}(y,1) + length(AllFiltersTrain);
    end
end
AllImages = [AllImagesTrain; AllImages];





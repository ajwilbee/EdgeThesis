%takes the output from the main program and formats it for analysis in
%excel add in the ,3 for when all of the filter information is present
OccurancesFilterSolveImage = zeros(512,2);
OccurancesFilterSolveImage(:,1) = (1:1:512);
OccurancesFilterWithDifferentFuzzyBoundary = zeros(512,2);
OccurancesFilterWithDifferentFuzzyBoundary(:,1) = (1:1:512);
for x =1: size(AllImages,1)
   temp = AllImages{x,1};
   AllImages{x,2} =AllFilters{temp}(3);%,3
   OccurancesFilterSolveImage(AllImages{x,1},2) = OccurancesFilterSolveImage(AllImages{x,1},2) + 1;
end
for x =1:length(AllFilters)
    OccurancesFilterWithDifferentFuzzyBoundary(AllFilters(x),2) = OccurancesFilterWithDifferentFuzzyBoundary(AllFilters(x),2)+1;%,3
end

       OccurancesFilterSolveImage(OccurancesFilterSolveImage(:,2) == 0,:) = [];
       OccurancesFilterWithDifferentFuzzyBoundary(OccurancesFilterWithDifferentFuzzyBoundary(:,2) == 0,:) = [];

csvwrite('OccurancesFilterWithDifferentFuzzyBoundary.csv',OccurancesFilterWithDifferentFuzzyBoundary)
csvwrite('OccurancesFilterSolveImage.csv',OccurancesFilterSolveImage)
csvwrite('ImagePairedWithFilter.csv',AllImages);

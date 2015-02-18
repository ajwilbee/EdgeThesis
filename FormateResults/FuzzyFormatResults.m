%mid phase Results needs to be finished off once it is determined what is
%important.
% OccurancesFilterSolveImage = zeros(512,2);
% OccurancesFilterSolveImage(:,1) = (1:1:512);
% OccurancesFilterWithDifferentFuzzyBoundary = zeros(512,2);
% OccurancesFilterWithDifferentFuzzyBoundary(:,1) = (1:1:512);
% for x =1: size(AllImages,1)
%     for y =1: size(AllImages{x,3},1)
%     end
%    temp = AllImages{x,1};
%    AllImages{x,3} =AllFilters{temp}(3);%,3
%    OccurancesFilterSolveImage(AllImages{x,1},2) = OccurancesFilterSolveImage(AllImages{x,1},2) + 1;
% end
% for x =1:length(AllFilters)
%     OccurancesFilterWithDifferentFuzzyBoundary(AllFilters(x),2) = OccurancesFilterWithDifferentFuzzyBoundary(AllFilters(x),2)+1;%,3
% end
% 
%        OccurancesFilterSolveImage(OccurancesFilterSolveImage(:,2) == 0,:) = [];
%        OccurancesFilterWithDifferentFuzzyBoundary(OccurancesFilterWithDifferentFuzzyBoundary(:,2) == 0,:) = [];
% 
% csvwrite('OccurancesFilterWithDifferentFuzzyBoundary.csv',OccurancesFilterWithDifferentFuzzyBoundary)
% csvwrite('OccurancesFilterSolveImage.csv',OccurancesFilterSolveImage)
% csvwrite('ImagePairedWithFilter.csv',AllImages);

%load Resulting edge image and chosenFilters
BDM = zeros(length(ResultingEdgeImage),1);
Sobel = zeros(length(ResultingEdgeImage),1);
Canny = zeros(length(ResultingEdgeImage),1);
Filters = zeros(length(ResultingEdgeImage),3);
    for y = 1: length(ResultingEdgeImage)
      
           BDM(y) = ResultingEdgeImage(y).BDM;

           Sobel(y) = ResultingEdgeImage(y).SobelBDM;
       
           Canny(y) = ResultingEdgeImage(y).CannyBDM;
           
           Filters(y,:) = ResultingEdgeImage(y).Filter;

    end
    A = cell2mat(AllFilters')';
    out = [BDM Sobel Canny Filters]; 
    temp = sum(out(:,1:6));
    temp = padarray(temp,[0,size(out,2)-length(temp)],'post');
    out(end+1,:) = temp;
csvwrite('ResultPlot.csv',out);
csvwrite('ChosenFilters.csv',A);

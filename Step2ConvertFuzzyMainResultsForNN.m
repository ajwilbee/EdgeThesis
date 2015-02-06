% Requires AllFilters and AllImages from filter generation portion of code
%
%this function reduces the number of filters to be used by successively
%identifying the most common filter which will accomplish the objective of
%out performing the standard filters and then removing all filters for that
%image from the pool. this is repeated until there are no filters left in
%the pool and the single filter which will be used for each image is
%identified. finally these filters are encoded for use in the NN
%remove empty filter counts
clear remove
GT = 1;
StorageLocation = 'C:\Users\ajw4388\Documents\Thesis\Results\FuzzySystem\Fuzzy_PSO_AllImages_FilterGeneration_GT1_feb3_Train_100Iter\Run1';
mkdir(StorageLocation);
for x = 1:size(AllFilters,1)
    
    if isempty(AllFilters{x})
      remove(x) = (1);
    else
        remove(x) = (0);
    end
    
end
remove = logical(remove);
if(~isempty(remove))
    AllFilters(remove,:) = [];
end
clear remove
for x = 1:size(AllImages,1)
    
    if isempty(AllImages{x,3})
      remove(x) = (1);
    else
        remove(x) = (0);
    end
    
end
remove = logical(remove);
if(~isempty(remove))
    AllImages(remove,:) = [];
end
FinalFilters = zeros(length(AllFilters),1);
AllImageFilters = zeros(length(AllFilters),2);
KeepGoing = logical(1);

while(KeepGoing)
    FinalCount = zeros(length(AllFilters),1);
    %count how many times each filter solves an image
    for x = 1:size(AllImages,1)
        for y = 1: size(AllImages{x,3},1)
            FinalCount(AllImages{x,3}(y,1)) = FinalCount(AllImages{x,3}(y,1))+1;
        end
    end
    c = 1;

    %zero out the index of the most effective filter
    remove = find(FinalCount == max(FinalCount),1);
    FinalCount(remove) = 0;
    % SingularFilters = 0;
    
    for x = 1:size(AllImages,1)
        kill = logical(ones(size(AllImages{x,3},1),1));
        go = 0;
        for y = 1: size(AllImages{x,3},1)

            if(AllImages{x,3}(y,1) == remove)
                 AllImageFilters(x,:) = AllImages{x,3}(y,:); %copy the filter over
                 go = 1;
                 break;
            end
        end
        if(go)
            
            AllImages{x,3}(kill,:) = [];
        end
    end

    FinalFilters(remove) = 1;
    KeepGoing = 0;
    for x = 1:size(AllImages,1)
         if( size(AllImages{x,3},1) > 0)
             KeepGoing = 1;
         end
    end
end
FinalFilters = logical(FinalFilters);
[B I] = sort(FinalFilters,'descend');
for x = 1:size(AllImageFilters,1)
    AllImageFilters(x,1) = find(I == AllImageFilters(x,1),1);
end
temp = max(AllImageFilters(:,1));
temp = dec2bin(temp);
temp = temp-'0';
numNNOutputs = length(temp);

for x = 1:size(AllImages,1)
    temp = (dec2bin(AllImageFilters(x,1))-'0')';
    if(length(temp) < numNNOutputs)
       temp = padarray(temp,numNNOutputs-length(temp),'pre'); 
    end
    AllImages{x,7} = temp;% the binary representation    
    AllImages{x,3} = AllImageFilters(x,:);
end


AllFilters(~FinalFilters) = [];
Sizes = [25 50 100];
save([StorageLocation,'\ChosenFilters'], 'AllFilters')
      
for sizeiter = 1:length(Sizes)
    dirName = [StorageLocation '\FinalResults_NNSize_' num2str(Sizes(sizeiter)),'_GroundTruth_' num2str(GT)];
    mkdir(dirName)
    ResultNN = Main_Fuzzy_Classification(AllImages,sizeiter,dirName);
    save([dirName,'\NeuralNetwork'], 'ResultNN');    
    [ResultingEdgeImage,BetterPerformance] = FuzzyRun(ResultNN,AllFilters,dirName);    
end
save([StorageLocation,'\ChosenFilters'], 'AllFilters')
% SingularFilters = 0;




%for all images with only one solution filter save that filter
% lengths = zeros(size(AllImages,1),1);
% for x = 1:size(AllImages,1)
%     lengths(x) = size(AllImages{x,3},1);
% end
% m = min(lengths);
% saveFilters = AllImages(lengths == m,3);
% FinalFilters = zeros(length(AllFilters),1);
% for x = 1:length(saveFilters)
%     FinalFilters(saveFilters{x}(1)) = 1;
% end
% for y = 1:size(AllImages,1)
%     remove2 = zeros(size(AllImages{y,3},1),1);
%     if(size(AllImages{y,3},1)>1)
%         for x = 1: size(AllImages{y,3},1)
%             if(FinalFilters(AllImages{y,3}(x,1)) == 1)
%                  AllImages{y,3}(x,:) = 1;
%                  break;
%             end
%         end
%     end
% end
%  AllImages(x,:) = []; 
%        x = x-2;
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
% StorageLocation = 'C:\Users\ajw4388\Documents\Thesis\Results\FuzzySystem\Feb5\Fuzzy_PSO_AllImages_FilterGeneration_GT1_feb5_Train\Run9_TrainAndTest_NewNNEncoding';
% mkdir(StorageLocation);
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
AllImageFilters = zeros(length(AllFilters),2); %has a list of final filters paired with images
KeepGoing = logical(1);
AllImagesCopy = AllImages;
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
    
    %zero out the filters for all images that are solved by the remove
    %filter
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

    FinalFilters(remove) = 1;%indicates a filter to be kept because it solves images best
    KeepGoing = 0;
    for x = 1:size(AllImages,1)
         if( size(AllImages{x,3},1) > 0)
             KeepGoing = 1;
         end
    end
end
FinalFilters = logical(FinalFilters);

[vals index] = find(FinalFilters == 1);
% go through all the filters attached to an image and remove the ones that
% are not on the final filter list
for x = 1:size(AllImagesCopy,1)
     for y = 1: size(AllImagesCopy{x,3},1)
         remove = 1;
         for z = 1:length(index)
            if(AllImagesCopy{x,3}(y,1) == index(z))
                remove = 0;
            end
         end
         if(remove)
            AllImagesCopy{x,3}(y,1) = [];
         end
     end
end

%ensure that the lowest value BDM of the available filters is chosen
for x = 1:size(AllImagesCopy,1)
     for y = 1: size(AllImagesCopy{x,3},1)
        if( AllImagesCopy{x,3}(y,2) < AllImageFilters(x,2))
            AllImageFilters(x,:) = AllImagesCopy{x,3}(y,:);
        end
     end     
end

[B I] = sort(FinalFilters,'descend');
for x = 1:size(AllImageFilters,1)
    AllImageFilters(x,1) = find(I == AllImageFilters(x,1),1);
end
temp = max(AllImageFilters(:,1));
temp = dec2bin(temp);
temp = temp-'0';
numNNOutputs = length(temp);

for x = 1:size(AllImages,1)
    AllImages{x,3} = AllImageFilters(x,:);
end


AllFilters(~FinalFilters) = [];

%map the duplicates to the lowest filter number occurance and then
%eliminater all others while maintaining the indexing

Mapping = 0;
for x = 1:length(AllFilters)
    count2 = 1;
    for y = x+1:length(AllFilters)
        if(AllFilters{x} == AllFilters{y})
            Mapping(x,count2) = y;
            count2 = count2+1;
        end
    end
end
for a =1: size(Mapping,1)
    temp = Mapping(a,:);
    temp(temp == 0) = [];
    for b =1: length(temp)
        for x = 1:size(AllImages,1)
            
                 if(AllImages{x,3}(1) == temp(b))
                     AllImages{x,3}(1) = a;
                 end
        
        end
    end
end
FilterUsed = zeros(length(AllFilters),1);



for x = 1:size(AllImages,1)
    
        
          FilterUsed(AllImages{x,3}(1)) =    1;
         
   
end
%sort the filters so that the gaps are removed and pushed to the bottom use
%the index I to keep the consistancy with the AllImages array
AllFilters(~FilterUsed) = [];

temp = sum(FilterUsed);
temp = dec2bin(temp);
temp = temp-'0';
numNNOutputs = length(temp);




[B I] = sort(FilterUsed,'descend');
for x = 1:size(AllImages,1)
    AllImages{x,3}(1) = find(I == AllImages{x,3}(1),1);
    
    %true value encoding for NN
    temp = zeros(length(AllFilters),1);
    temp(AllImages{x,3}(1)) = 1;
% Old binary encoding method for NN    
%     temp = (dec2bin(AllImages{x,3}(1))-'0')';
%     if(length(temp) < numNNOutputs)
%        temp = padarray(temp,numNNOutputs-length(temp),'pre'); 
%     end
    AllImages{x,7} = temp;% the binary representation    
    

end


Sizes = [25 50 100];
save([StorageLocation,'\ChosenFilters'], 'AllFilters')
      
for sizeiter = 1:length(Sizes)
    dirName = [StorageLocation '\FinalResults_NNSize_' num2str(Sizes(sizeiter)),'_GroundTruth_' num2str(GT)];
    mkdir(dirName)
    ResultNN = Main_Fuzzy_Classification(AllImages,Sizes(sizeiter),dirName);
    save([dirName,'\NeuralNetwork'], 'ResultNN');    
    [ResultingEdgeImage,BetterPerformance] = FuzzyRun(ResultNN,AllFilters,dirName);    
end
save([StorageLocation,'\ChosenFilters'], 'AllFilters')


function [AllInputs,AllOutputs] = NNResample( ReducedFeatures, AllTargets, LayerSize )
%UNTITLED4 Summary of this function goes here
%   Increase the # samples by resampling with replacement
%   ReducedFeatures: The input features for a NN
%   AllTargets: The output features for a NN
%   LayerSize: the hidden layer size
%only works for single hidden layer systems

    NumHidden = LayerSize;
    NumOutput = size(AllTargets,1);
    NumInput = size(ReducedFeatures,1);

    allSum = sum(AllTargets');
    [m i] = max(allSum);
    allAdds = floor((m*(ones(1,length(allSum))))./allSum);
    allAdds(allAdds == Inf) = 0
    numElements = sum(allSum.*allAdds);

    NewAllTargets = zeros(size(AllTargets,1),numElements);
    NewReducedFeatures = zeros(size(ReducedFeatures,1),numElements);

    %build a new dataset to force there to be the same number of samples
    %for each filter.
    count = 1;

    for x = 1:size(AllTargets,2)
        numAdd = max(AllTargets(:,x).*allAdds');

        for y = 1:numAdd
            NewAllTargets(:,count) = AllTargets(:,x);
            NewReducedFeatures(:,count) =  ReducedFeatures(:,x);
            count = count +1;
        end

    end

    AllTargets = NewAllTargets;
    ReducedFeatures = NewReducedFeatures;
    allSum = sum(AllTargets');

    
    SamplesNeeded = (NumHidden*NumInput+NumHidden*NumOutput+NumHidden+NumOutput);
    AllInputs = zeros(NumInput,SamplesNeeded);
    AllOutputs = zeros(NumOutput,SamplesNeeded);

    ScaleFactor = size(AllTargets,2);
    %sample with replacement of all values in the sample space
    for x = 1:SamplesNeeded
        index = ceil(rand*ScaleFactor);
        AllInputs(:,x) = ReducedFeatures(:,index);
        AllOutputs(:,x) = AllTargets(:,index);
    end

    AllInputs = [AllInputs ReducedFeatures];
    AllOutputs = [AllOutputs AllTargets];

end


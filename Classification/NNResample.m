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

    SamplesNeeded = (NumHidden*NumInput+NumHidden*NumOutput+NumHidden+NumOutput)*10;
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


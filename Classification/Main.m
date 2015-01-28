%This is the Main Function for the none fuzzy input data
%The filter generator will create a file which contains an array of
%structures, these stuctures will have the following fields
%'ImageFile' - The image that the filter was generated for (color)
%'GroundTruthFile' - The ground truth image (black and white)
%'GroundTruthNumber' - which of the 5 ground truths was used for this filter
%'FilterMask' - the filter mask used for the output image (3x3)
%'NNOutput' - the filter mask in form useful for the NN (1X9)
%'BDM'- the BDM index for goodness of edge image
%'OutputImage' - the output edge image using the filter on the input image

%load('C:\Users\ajw4388\Documents\MATLAB\TestOutputFile.mat');
%FilterGeneratorValues = outputValues;

for x = 1:size(FilterGeneratorValues,1)
   AllImages{x} = FilterGeneratorValues(x).ImageFile;
    AllTargetsCell{x} = FilterGeneratorValues(x).TrueNNOutput;
end
outputfileLocation = 'C:\Users\ajw4388\Documents\MATLAB\CorrectedFeaturesTest';

temp = FeatureExtractionFunc(AllImages);
AllFeatures = temp{1};

%to reduce the number of elements being used during testing
%AllFeatures = temp{1}(1:end,1:round(end/divider));
%AllTargets =  temp{2}(1:round(end/divider))';
count = 2;
% for x = 4:length(imageDirs)
%     temp = FeatureExtractionFunc([inputDir '\' imageDirs(x).name]);
%    % Features = 0;
%     save([outputfileLocation '\' imageDirs(x).name]  ,'Features');% imageDirs(x).name
%     AllFeatures = [AllFeatures temp{1}(1:end,1:round(end/divider))];
%     %AllTargets = [AllTargets temp{2}(1:round(end/divider))'*count];
%     count = count +1;
% end

[Z, W, E, mVal,mVar]=myPCA(AllFeatures',.99);
meanMat = ones(size(AllFeatures'))*diag(mVal);
reducedFeatures = ((AllFeatures'-meanMat)*W)';

% create the target values from input data
% AllTargets = zeros(9,length(FilterGeneratorValues));
% for x = 1:length(FilterGeneratorValues)
%    AllTargets(:,x) =  FilterGeneratorValues(x).NNOutput;
% end
AllTargets = cell2mat(AllTargetsCell')';

%[ reducedFeatures ,trueclass] = ShuffleTrainingdata( reducedFeatures,AllTargets );

% TargetMatrix = zeros(max(trueclass),length(trueclass));
% for i = 1:length(trueclass)
%     TargetMatrix(trueclass(i),i) = 1;
% end
LayerSize = 50;

 net = feedforwardnet(LayerSize);
 net = train(net,reducedFeatures,AllTargets);
 

%  net = patternnet(LayerSize,'trainscg','crossentropy');
%  net = train(net,reducedFeatures,TargetMatrix);
 
 output = net(reducedFeatures);

 performance = perform(net, output,AllTargets);
 plotconfusion(AllTargets, output);
 save([filename ,'_All'])

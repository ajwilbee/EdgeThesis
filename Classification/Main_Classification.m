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
for GT = 1:size(FilterGeneratorValues,2)
    clear AllImages AllTargetsCell
    count = 1;
    for x = 1:size(FilterGeneratorValues,1)
        if(~isempty(FilterGeneratorValues(x,GT).GroundTruthFile))
            AllImages{count} = FilterGeneratorValues(x,GT).ImageFile;
            AllTargetsCell{count} = FilterGeneratorValues(x,GT).TrueNNOutput;
            count = count +1;
        end

    end
    if(count > (size(FilterGeneratorValues,1)/2))

        temp = FeatureExtractionFunc(AllImages);
        AllFeatures = temp{1};        

        [Z, W, E, mVal,mVar]=myPCA(AllFeatures',.99);
        meanMat = ones(size(AllFeatures'))*diag(mVal);
        ReducedFeatures = ((AllFeatures'-meanMat)*W)';

        % create the target values from input data
        AllTargets = cell2mat(AllTargetsCell')';

        Sizes = [25 50 100];
        for sizeiter = 1:length(Sizes)
            LayerSize = Sizes(sizeiter);
            [ReducedFeatures, AllTargets]=NNResample( ReducedFeatures, AllTargets, LayerSize );
            %  net = feedforwardnet(LayerSize);
            %  net = train(net,ReducedFeatures,AllTargets);


             net = patternnet(LayerSize,'trainscg','crossentropy');
             
             net = train(net,ReducedFeatures,AllTargets);

             output = net(ReducedFeatures);

             performance = perform(net, output,AllTargets);
             plotconfusion(AllTargets, output);
             ResultNN =  struct('InputFeatures',ReducedFeatures,'OutputValues',AllTargets,'NeuralNetwork',net,'Mean',mVal,'Variance',mVar,'PCATransformationMatrix',W,'LayerSize',LayerSize);
             save(['ResultNNValidation_LayerSize' num2str(LayerSize) '_GroundTruth_' num2str(GT)], 'ResultNN');
        end
    end
end

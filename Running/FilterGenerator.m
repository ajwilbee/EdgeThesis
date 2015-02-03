% need the Proper CannySobelBDMFile to get the images from
% need the correct ResultNNValiation file to get the ResultNN struct
dirName = 'Jan29NonFuzzyFilterFinalResultsFirstTrial';
mkdir(dirName)
for GT = 1:size(CannySobelBDM,2)
    clear AllImages AllTargetsCell
    count = 1;
    clear AllImages AllTargetsCell names SobelEdgeImage SobelBDM CannyEdgeImage CannyBDM
    for x = 1:size(CannySobelBDM,1)
            if(~isempty(CannySobelBDM(x,GT).GroundTruthFile))
                AllImages{count} = CannySobelBDM(x,GT).ImageFile;
                AllTargetsCell{count} = CannySobelBDM(x,GT).GroundTruthFile;
                names{count} = CannySobelBDM(x,GT).ImageName;
                
                    SobelEdgeImage{count} = CannySobelBDM(x,GT).OutputImage_Sobel;
                    SobelBDM(count) = CannySobelBDM(x,GT).BDM_Sobel ;
               
                    CannyEdgeImage{count} = CannySobelBDM(x,GT).OutputImage_Canny;
                    CannyBDM(count) = CannySobelBDM(x,GT).BDM_Canny ;
                
                count = count +1;
            end

    end
    if(count > (size(FilterGeneratorValues,1)/2))

        temp = FeatureExtractionFunc(AllImages);
        AllFeatures = temp{1}; 
        mVal = ResultNN.Mean;
        W = ResultNN.PCATransformationMatrix;
        meanMat = ones(size(AllFeatures'))*diag(mVal);
        net = ResultNN.NeuralNetwork;
        net.layers{2}.transferFcn = 'tansig';
        ReducedFeatures =((AllFeatures'-meanMat)*W)';

        output = net(ReducedFeatures)>0;
        figure(1);title('BDM Comparison');
        for x = 1:size(AllImages,2)
            Filter = bin2dec(num2str(output(:,1))');%get number for CA filter to use
            [BDM, EdgeImage] = fit_ness(double(im2bw(rgb2gray(AllImages{x}),0.4)),AllTargetsCell{x}, Filter);
            
            subplot(2,2,1);imshow(AllTargetsCell{x});title(['GroundTruth ' num2str(GT)]);
            subplot(2,2,2);imshow(EdgeImage);title(['Test BDM = ' num2str(BDM)]);
            subplot(2,2,3);imshow( SobelEdgeImage{x});title(['Sobel BDM = ' num2str(SobelBDM(x))]);
            subplot(2,2,4);imshow( CannyEdgeImage{x});title(['Canny BDM = ' num2str(CannyBDM(x))]);
            saveas(figure(1),strcat(dirName, '\', names{x}, 'GroundTruth_', num2str(GT)),'jpg')
            ResultingEdgeImage(x) = struct('BDM',BDM,'EdgeImage', EdgeImage,...
                'GroundTruth',AllTargetsCell{x},'Original',AllImages{x},'ImageName', names{x},...
                'SobelEdgeImage', SobelEdgeImage{x},'SobelBDM',SobelBDM(x),...
                'CannyEdgeImage',CannyEdgeImage{x},'CannyBDM',CannyBDM(x) );
            if(BDM >CannyBDM(x) && BDM >SobelBDM(x))
                BetterPerformance(x) = 1;
            else
                BetterPerformance(x) = 0;
            end
        end
    end
    save([dirName '/_ResultingEdgeImage_GT' num2str(GT)], 'ResultingEdgeImage');
     save([dirName '/_BetterPerformance_GT' num2str(GT)], 'BetterPerformance');%one if yes 0 if no

    
end
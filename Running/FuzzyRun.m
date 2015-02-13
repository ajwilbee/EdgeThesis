function [ResultingEdgeImage,BetterPerformance] = FuzzyRun(ResultNN,AllFilters,dirName)

%fuzzy System
% takes the NN from the fuzzy system and applies it to input images
% takes the Proper CannySobelBDMFile
% takes correct ResultNNValidation File to get the ResultNN struct
% takes allFilter File from Step2
GT = 1;




load('C:\Users\ajw4388\Documents\MATLAB\Thesis_Code\CannySobelBDM\CannySobelBDMValidation.mat')  
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
        FilterIndex = bin2dec(num2str(output(:,x))');%get number for CA filter to use
        if(FilterIndex > length(AllFilters))
           FilterIndex = length(AllFilters)
        end
        Filter = AllFilters{FilterIndex};
        [BDM, EdgeImage] = fuzzy_fitness(double(rgb2gray(AllImages{x})),AllTargetsCell{x}, Filter);

        subplot(2,2,1);imshow(AllTargetsCell{x});title(['GroundTruth ' num2str(GT)]);
        subplot(2,2,2);imshow(EdgeImage);title(['Test BDM = ' num2str(BDM)]);
        subplot(2,2,3);imshow( SobelEdgeImage{x});title(['Sobel BDM = ' num2str(SobelBDM(x))]);
        subplot(2,2,4);imshow( CannyEdgeImage{x});title(['Canny BDM = ' num2str(CannyBDM(x))]);
        saveas(figure(1),strcat(dirName, '/', names{x}, 'GroundTruth_', num2str(GT)),'jpg')
        ResultingEdgeImage(x) = struct('BDM',BDM,'EdgeImage', EdgeImage,...
            'GroundTruth',AllTargetsCell{x},'Original',AllImages{x},'ImageName', names{x},...
            'SobelEdgeImage', SobelEdgeImage{x},'SobelBDM',SobelBDM(x),...
            'CannyEdgeImage',CannyEdgeImage{x},'CannyBDM',CannyBDM(x),'Filter',Filter );
        %if BDM is lower than the performance was better
        if(BDM <CannyBDM(x) && BDM <SobelBDM(x))
            BetterPerformance(x) = 1;
        else
            BetterPerformance(x) = 0;
        end
    end
    
    save([dirName '/_ResultingEdgeImage_GT' num2str(GT)], 'ResultingEdgeImage');
    save([dirName '/_BetterPerformance_GT' num2str(GT)], 'BetterPerformance');%one if yes 0 if no
     
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
        out = [BDM Sobel Canny Filters BetterPerformance']; 
    csvwrite([dirName,'\ResultPlot.csv'],out);
    csvwrite([dirName,'\ChosenFilters.csv'],A);
    
end

    

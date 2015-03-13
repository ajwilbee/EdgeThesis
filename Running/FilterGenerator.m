function [ResultingEdgeImage,BetterPerformance] = FilterGenerator(ResultNN,dirName,FilterGeneratorValues)
% need the Proper CannySobelBDMFile to get the images from
% need the correct ResultNNValiation file to get the ResultNN struct

load('C:\Users\ajw4388\Documents\MATLAB\Thesis_Code\CannySobelBDM\CannySobelBDMTestingNNSparse.mat')
mkdir(dirName)
    for GT = 1:1%size(CannySobelBDM,2)
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
                        
                         PrewittEdgeImage{count} = CannySobelBDM(x,GT).OutputImage_Prewitt;
                    PrewittBDM(count) = CannySobelBDM(x,GT).BDM_Prewitt ;
                    
                    RobertsEdgeImage{count} = CannySobelBDM(x,GT).OutputImage_Roberts;
                    RobertsBDM(count) = CannySobelBDM(x,GT).BDM_Roberts ;
                    
                    LogEdgeImage{count} = CannySobelBDM(x,GT).OutputImage_Log;
                    LogBDM(count) = CannySobelBDM(x,GT).BDM_Log;

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
                Filter = bin2dec(num2str(output(:,x))');%get number for CA filter to use
                [BDM, EdgeImage] = fit_ness(double(im2bw(rgb2gray(AllImages{x}),0.4)),AllTargetsCell{x}, Filter);

                subplot(3,3,1);imshow(AllImages{x});title(['Original Image ' names(x)]);
        subplot(3,3,3);imshow(AllTargetsCell{x});title(['GroundTruth ' num2str(GT)]);
        subplot(3,3,4);imshow(EdgeImage);title(['Test BDM = ' num2str(BDM)]);
        subplot(3,3,5);imshow( SobelEdgeImage{x});title(['Sobel BDM = ' num2str(SobelBDM(x))]);
        subplot(3,3,6);imshow( CannyEdgeImage{x});title(['Canny BDM = ' num2str(CannyBDM(x))]);
        subplot(3,3,7);imshow( PrewittEdgeImage{x});title(['Prewitt BDM = ' num2str(PrewittBDM(x))]);
        subplot(3,3,8);imshow( RobertsEdgeImage{x});title(['Roberts BDM = ' num2str(RobertsBDM(x))]);
        subplot(3,3,9);imshow( LogEdgeImage{x});title(['Log BDM = ' num2str(LogBDM(x))]);
                saveas(figure(1),strcat(dirName, '\', names{x}, 'GroundTruth_', num2str(GT)),'jpg')
                ResultingEdgeImage(x) = struct('BDM',BDM,'EdgeImage', EdgeImage,...
                    'GroundTruth',AllTargetsCell{x},'Original',AllImages{x},'ImageName', names{x},...
                    'SobelEdgeImage', SobelEdgeImage{x},'SobelBDM',SobelBDM(x),...
                    'CannyEdgeImage',CannyEdgeImage{x},'CannyBDM',CannyBDM(x),'Filter',Filter);
                if(BDM <CannyBDM(x) && BDM <SobelBDM(x))
                    BetterPerformance(x) = 1;
                else
                    BetterPerformance(x) = 0;
                end
            end

        save([dirName '/_ResultingEdgeImage_GT' num2str(GT)], 'ResultingEdgeImage');
         save([dirName '/_BetterPerformance_GT' num2str(GT)], 'BetterPerformance');%one if yes 0 if no
         
            BDM = zeros(length(ResultingEdgeImage),1);

            Filters = zeros(length(ResultingEdgeImage),1);
            for y = 1: length(ResultingEdgeImage)

               BDM(y) = ResultingEdgeImage(y).BDM;



               Filters(y) = ResultingEdgeImage(y).Filter;

            end
names = zeros(size(CannySobelBDM,1),1);
for x = 1:size(CannySobelBDM,1)
    names(x) = str2num(CannySobelBDM(x,1).ImageName(1:end));
    
end
             out = [BDM SobelBDM' CannyBDM' PrewittBDM' RobertsBDM' LogBDM' Filters BetterPerformance' names]; 
            csvwrite([dirName '\ResultPlotGT' num2str(GT) '.csv'],out);


    end
end
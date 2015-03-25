%Thesis formated output
%needs ResultNN,dirName,FilterGeneratorValues,CSBDMFileLocation
mkdir(dirName)
   
        clear AllImages AllTargetsCell
        count = 1;
        clear AllImages AllTargetsCell names SobelEdgeImage SobelBDM CannyEdgeImage CannyBDM
        for x = 1:size(CannySobelBDM,1)
                if(~isempty(CannySobelBDM(x,1).GroundTruthFile))
                    AllImages{count} = CannySobelBDM(x,1).ImageFile;
                end
        count = count + 1;
        end

        count = 1;
            temp = FeatureExtractionFunc(AllImages);
            AllFeatures = temp{1}; 
            mVal = ResultNN.Mean;
            W = ResultNN.PCATransformationMatrix;
            meanMat = ones(size(AllFeatures'))*diag(mVal);
            net = ResultNN.NeuralNetwork;
            net.layers{2}.transferFcn = 'tansig';
            ReducedFeatures =((AllFeatures'-meanMat)*W)';

            output = net(ReducedFeatures)>0;
for GT = 1:5
    
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
        count = 1;
            
            for x = 1:size(AllImages,2)
                Filter = bin2dec(num2str(output(:,x))');%get number for CA filter to use
                [BDM, EdgeImage] = fit_ness(double(im2bw(rgb2gray(AllImages{x}),0.4)),AllTargetsCell{x}, Filter);
                imwrite(AllTargetsCell{x},strcat(dirName, '\', names{x},'GT', num2str(GT),'.png'))
                if GT == 1
                    
                    imwrite(AllImages{x},strcat(dirName, '\', names{x},'.png'));
                    imwrite(EdgeImage,strcat(dirName, '\', names{x},'test','.png'))
                    imwrite( SobelEdgeImage{x},strcat(dirName, '\', names{x},'Sobel','.png'))
                    imwrite( CannyEdgeImage{x},strcat(dirName, '\', names{x},'Canny','.png'))
                    imwrite( PrewittEdgeImage{x},strcat(dirName, '\', names{x},'Prewitt','.png'))
                    imwrite( RobertsEdgeImage{x},strcat(dirName, '\', names{x},'Roberts','.png'))
                    imwrite( LogEdgeImage{x},strcat(dirName, '\', names{x},'LoG','.png'))
                end
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
         
            BDM = zeros(length(ResultingEdgeImage),1);

            Filters = zeros(length(ResultingEdgeImage),1);
            for y = 1: length(ResultingEdgeImage)

               BDM(y) = ResultingEdgeImage(y).BDM;



               Filters(y) = ResultingEdgeImage(y).Filter;

            end
            
            minarray = [BDM,SobelBDM',CannyBDM',PrewittBDM',RobertsBDM',LogBDM'];
            [A, maxarrayIndex] = min(minarray');
            minarray = zeros(size(minarray));
            for c = 1:length(minarrayIndex)
               minarray(c,minarrayIndex(c)) = 1; 
            end
            
            BDM(end+1) = sum(BDM);
            SobelBDM(end+1) = sum(SobelBDM);
            CannyBDM(end+1) = sum(CannyBDM);
            PrewittBDM(end+1) = sum(PrewittBDM);
            RobertsBDM(end+1) = sum(RobertsBDM);
            LogBDM(end+1) = sum(LogBDM);
            Filters(end+1) = 0;
            BetterPerformance(end+1) = sum(BetterPerformance);
            
names1 = zeros(size(CannySobelBDM,1),1);
for x = 1:size(CannySobelBDM,1)
    names1(x) = str2num(CannySobelBDM(x,1).ImageName(1:end));
    
end
names1(end+1) = 0;

out = [BDM SobelBDM' CannyBDM' PrewittBDM' RobertsBDM' LogBDM' Filters BetterPerformance' names1]; 
            csvwrite([dirName '\ResultPlotGT' num2str(GT) '.csv'],out);
            csvwrite([dirName '\MaxArray' num2str(GT) '.csv'],minarray);
            clear SobelBDM
clear CannyBDM
clear PrewittBDM
clear RobertsBDM
clear LogBDM
clear BDM
clear Filters
clear BetterPerformance
clear minarray
end
%% PSO for CA_Fuzzy Edge Detection

%% main.m, mpPSO.m, fit_ness.m, maskCA.m
%% 10/10/2013 2013 Edge Detection �al??mas? tamamland?.
close all
%clear all
clc
%%
% ImageFilesPath = 'C:\Users\ajw4388\Documents\Thesis\Berkely_Segmentation_Set\BSDS500\data\images\Train';
% GroundTruthFilesPath = 'C:\Users\ajw4388\Documents\Thesis\Berkely_Segmentation_Set\BSDS500\data\groundTruth\Train';
load('CannySobelBDMTrainingNNSparse.mat')
ImageSaveFolderName = 'Testing'; % make this ahead of time
ImageSaveFolder = [pwd '/' ImageSaveFolderName];
mkdir(ImageSaveFolder);




%%
iteration =1;
for i=1:1%length(CannySobelBDM)
%starting point for PSO: 1-> division offset 2-> fuzzy boundery 3-> CA rule
    parameters = [23;124;321;452;35;326;168;245;410;203;
                  123;24;121;45;355;56;18;45;386;178;];%last parameter must be the CA neighborhood rule
    imFullName =CannySobelBDM(1).ImageName;
    im1 = CannySobelBDM(1).ImageFile;
    size(parameters);
    c1 =2.01;% velocity modifier
    c2 = 2.01;% velocity modifier
    [row,col] = size (im1);
    coef =[.73 c1 c2];% velocity modifier
    %dbstop in fit_ness
    %% 

    SizeofSwarm = size (parameters ,1);
    AllLocalCA_WeightPairs = zeros(2,SizeofSwarm,length(CannySobelBDM)); %CA,Fitness are dimension 1

 
     disp(i);
    imFullName =CannySobelBDM(i).ImageName;
    %disp(imFullName);
    im =  CannySobelBDM(i).ImageFile;
    imgGrey =double(im2bw(rgb2gray(im),0.4));
   
    
    
        imgGT = CannySobelBDM(i).GroundTruthFile;
        %mkdir(ImageSaveFolderName,['GroundTruth', num2str(whichGT)]);

        
        [bestParameters, best_BDM, localPositions,localFitness ] = myPSO(imgGrey, imgGT, coef, iteration, parameters);
        AllLocalCA_WeightPairs(1,:,i) = localPositions(1,:);
        AllLocalCA_WeightPairs(2,:,i) = localFitness';
        [bestPosition, bestCAEdgeImage] = fit_ness(imgGrey,imgGT, bestParameters); 
        imwrite(bestCAEdgeImage, strcat([ImageSaveFolder],'bestCAEdgeImage.jpg'));

%         figure(bestParameters(1,1));
%         subplot(2,3,1);imshow(imgGrey, []);
%         title(['First Image'])
%         subplot(2,3,2);imshow(imgGT);
%         title(['Ground Truth'])
%         subplot(2,3,3);imshow(CannySobelBDM(i).OutputImage_Sobel);
%         title(['Sobel Detection : ', num2str(CannySobelBDM(i).BDM_Sobel)])
%         subplot(2,3,4);imshow(CannySobelBDM(i).OutputImage_Canny);
%         title(['Canny Detection : ', num2str(CannySobelBDM(i).BDM_Canny)])
%         subplot(2,3,5);imshow(bestCAEdgeImage);
%         title(['Proposed Method: ', num2str(bestPosition)])
%         subplot(2,3,6);imshow(getMaskCA(bestParameters(1)));
%         title(['Utilized CA' num2str(bestParameters(1))])
%         saveas( figure(bestParameters(1)),strcat([ImageSaveFolderName],num2str(bestParameters(1)),'.jpg'),'jpg');
        
        temp = getMaskCA(bestParameters);
        CorrectFilterOutputsforTraining = reshape(temp',[1,9]);        
        FilterGeneratorValues(i) = struct('ImageFile', im,'GroundTruthFile',imgGT,'GroundTruthNumber',1,'FilterMask',temp,'TrueNNOutput',CorrectFilterOutputsforTraining,'BDM',num2str(bestPosition),'OutPutImage',bestCAEdgeImage);

        close all;
        i
    %save(strcat(['FilterGeneratorValuesSparse2' ] ),'FilterGeneratorValues');
 end
  save(strcat(['FilterGeneratorValuesSparse3' ] ),'FilterGeneratorValues','-v7.3');
    
 
%% PSO for CA_Fuzzy Edge Detection

%% main.m, mpPSO.m, fit_ness.m, maskCA.m
%% 10/10/2013 2013 Edge Detection çal??mas? tamamland?.
close all
%clear all
clc
%%
ImageFilesPath = 'C:\Users\ajw4388\Documents\Thesis\Berkely_Segmentation_Set\BSDS500\data\images\train';
GroundTruthFilesPath = 'C:\Users\ajw4388\Documents\Thesis\Berkely_Segmentation_Set\BSDS500\data\groundTruth\train';
ImageSaveFolderName = 'Non_Fuzzy_PSO_TrainedCAFilters1'; % make this ahead of time
ImageSaveFolder = [pwd '\' ImageSaveFolderName];
mkdir(ImageSaveFolder);

addpath(ImageFilesPath,GroundTruthFilesPath);
ImageFiles = dir(fullfile(ImageFilesPath, '*.jpg'));
GroundTruthFiles = dir(fullfile(GroundTruthFilesPath, '*.mat'));

%%
iteration =1;
%starting point for PSO: 1-> division offset 2-> fuzzy boundery 3-> CA rule
parameters = [23;124;321;452;35;326;168;245;410;203;
              123;24;121;45;355;56;18;45;386;178;];%last parameter must be the CA neighborhood rule
          imFullName =ImageFiles(1).name(1:end-4);
    im1 = imread(ImageFiles(1).name);
size(parameters);
c1 =2.01;% velocity modifier
c2 = 2.01;% velocity modifier
[row,col] = size (im1);
coef =[.73 c1 c2];% velocity modifier
whichGT = 2;
%dbstop in fit_ness
%% 

SizeofSwarm = size (parameters ,1);
AllLocalCA_WeightPairs = zeros(2,SizeofSwarm,length(ImageFiles)); %CA,Fitness are dimension 1

 for i=1:length(ImageFiles)
     disp(i);
    imFullName =ImageFiles(i).name(1:end-4);
    disp(imFullName);
    im = imread(ImageFiles(i).name);
    imgGrey =double(im2bw(rgb2gray(im),0.4));
    load(GroundTruthFiles(i).name);
    imgGT = double(groundTruth{1}.Boundaries);
    mkdir(ImageSaveFolderName,imFullName);
    imwrite(im,strcat([ImageSaveFolder '\' imFullName '\'],'Original.jpg'));
    imwrite(groundTruth{whichGT}.Boundaries,strcat([ImageSaveFolder '\' imFullName '\'],'GroundTruth.jpg'));

     sobel_edge =edge(rgb2gray(imread(ImageFiles(i).name)),'sobel',0.08);
     canny_edge =edge(rgb2gray(imread(ImageFiles(i).name)),'canny',0.1);
      imwrite(sobel_edge,strcat([ImageSaveFolder '\' imFullName '\'],'Sobel.jpg'));
      imwrite(canny_edge,strcat([ImageSaveFolder '\' imFullName '\'],'Canny.jpg'));
     se=im2double(sobel_edge);
     ce=im2double(canny_edge);
     [val_sobel, dMap] = BDM(imgGT,se,'x', 2, 'euc');
     [val_canny, dMap] = BDM(imgGT,ce,'x', 2, 'euc');
    
    [bestParameters, best_BDM, localPositions,localFitness ] = myPSO(imgGrey, imgGT, coef, iteration, parameters);
    AllLocalCA_WeightPairs(1,:,i) = localPositions(1,:);
    AllLocalCA_WeightPairs(2,:,i) = localFitness';
    [bestPosition, bestCAEdgeImage] = fit_ness(imgGrey,imgGT, bestParameters); 
    imwrite(bestCAEdgeImage, strcat([ImageSaveFolder '\' imFullName '\'],'bestCAEdgeImage.jpg'));
   
    figure(bestParameters(1,1));
    subplot(2,3,1);imshow(imgGrey, []);
    title(['First Image'])
    subplot(2,3,2);imshow(imgGT);
    title(['Ground Truth'])
    subplot(2,3,3);imshow(se);
    title(['Sobel Detection : ', num2str(val_sobel)])
    subplot(2,3,4);imshow(ce);
    title(['Canny Detection : ', num2str(val_canny)])
    subplot(2,3,5);imshow(bestCAEdgeImage);
    title(['Proposed Method: ', num2str(bestPosition)])
    subplot(2,3,6);imshow(getMaskCA(bestParameters(1)));
    title(['Utilized CA' num2str(bestParameters(1))])
    saveas( figure(bestParameters(1)),strcat([ImageSaveFolderName '\' imFullName '\'],num2str(bestParameters(1)),'.jpg'),'jpg');
    save(strcat([ImageSaveFolderName '\' imFullName '\'],num2str(bestParameters(1))));
    temp = getMaskCA(bestParameters);
    CorrectFilterOutputsforTraining = reshape(temp',[1,9]);
    if(i == 1)
        FilterGeneratorValues(length(ImageFiles)) = struct('ImageFile', im,'GroundTruthFile',imgGT,'GroundTruthNumber',bestParameters,'FilterMask',temp,'NNOutput',CorrectFilterOutputsforTraining,'BDM',num2str(bestPosition),'OutputImage',bestCAEdgeImage); 
    end
    FilterGeneratorValues(i) = struct('ImageFile', im,'GroundTruthFile',imgGT,'GroundTruthNumber',bestParameters,'FilterMask',temp,'NNOutput',CorrectFilterOutputsforTraining,'BDM',num2str(bestPosition),'OutPutImage',bestCAEdgeImage);
    close all;
 end
 saveas(strcat([ImageSaveFolderName '\' [ImageSaveFolderName, 'FilterGeneratorValues' ] ]),FilterGeneratorValues);
    
 
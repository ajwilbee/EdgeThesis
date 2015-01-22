%% PSO for CA_Fuzzy Edge Detection

%% main.m, mpPSO.m, fit_ness.m, maskCA.m
%% 10/10/2013 2013 Edge Detection çal??mas? tamamland?.
close all
%clear all
clc
%%
% takes in a list of images with ground truths, performs boosting approach
% to generate a set of filters to solve the edge detection of the images
% saves the filter parametes in one file and the list of which filter
% solves which image
ImageFilesPath = 'C:\Users\ajw4388\Documents\Thesis\Berkely_Segmentation_Set\BSDS500\data\images\test';
GroundTruthFilesPath = 'C:\Users\ajw4388\Documents\Thesis\Berkely_Segmentation_Set\BSDS500\data\groundTruth\test';
% load('MatFileResults\cannySobelBDM_DefaultSettings_AllGT.mat');
ImageSaveFolderName = 'Fuzzy_PSO_AllImages_FilterGeneration_GT1'; % make this ahead of time
ImageSaveFolder = [pwd '\' ImageSaveFolderName];
mkdir(ImageSaveFolder);

addpath(ImageFilesPath,GroundTruthFilesPath);
ImageFiles = dir(fullfile(ImageFilesPath, '*.jpg'));
GroundTruthFiles = dir(fullfile(GroundTruthFilesPath, '*.mat'));

%%
iteration =1;
%starting point for PSO: 1-> division offset 2-> fuzzy boundery 3-> CA rule
parameters = [60 0.3 23;79 1 124; 105 0 321; 23 0.3 452;78 0.01 35;92 0.6 326;73 0.43 168;86 0.87 245; 112 0.54 410;124 0.67 203;
              51 0.23 123;69 0.89 24; 101 0.34 121; 39 0.4 45;71 0.19 355;97 0.73 56;134 0.3 18;35 0.71 45;68 0.47 386;82 0.712 178;];
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

% SizeofSwarm = size (parameters ,1);
% AllLocalCA_WeightPairs = zeros(2,SizeofSwarm,length(ImageFiles)); %CA,Fitness are dimension 1
AllImages = cell(length(ImageFiles),2);

for i=1:length(ImageFiles)
%      imFullName =ImageFiles(i).name(1:end-4);
     AllImages{i,1} = double(rgb2gray(imread(ImageFiles(i).name)));
     load(GroundTruthFiles(i).name);
     AllImages{i,2} = double(groundTruth{whichGT}.Boundaries);
end

% this is greedy and will need to be revisited
count = 1;
AllFilters = 0;
 for i=1:length(ImageFiles)
     
    if(size(AllImages{i,1}) > 1)
            imgGrey = AllImages{i,1};
            imgGT = AllImages{i,2};
            mkdir(ImageSaveFolderName,imFullName);

            [bestParameters, best_BDM, localPositions,localFitness ] = myFuzzyPSO(imgGrey, imgGT, coef, iteration, parameters);


            [bestPosition, bestCAEdgeImage] = fuzzy_fitness(imgGrey,imgGT, bestParameters); 
            imwrite(bestCAEdgeImage, strcat([ImageSaveFolder '\' imFullName '\'],'bestCAEdgeImage.jpg'));
            AllImages{i,1} = count;
             AllImages{i,2} = count;
            for iter=1:length(AllImages)       
                if(size(AllImages{iter,1}) > 1)
                    tempImgGrey =AllImages{iter,1};       
                    tempImgGT = AllImages{iter,2};
                    BDM = fuzzy_fitness(tempImgGrey,tempImgGT, bestParameters); 
                    if(BDM < CannySobelBDM(iter).BDM_Sobel && BDM  < CannySobelBDM(iter).BDM_Canny)
                        AllImages{iter,1} = count;
                        AllImages{iter,2} = count;
                    end
                end
            end
            
            close all;
            AllFilters(count) = bestParameters(3);
            count = count +1;
    end
 end
 save(strcat([ImageSaveFolder '\' ['AllFilters' ] ]),'AllFilters'); %filters that solve images
 save(strcat([ImageSaveFolder '\' ['AllImages' ] ]),'AllImages'); % which filter sovles which image
 
    
 
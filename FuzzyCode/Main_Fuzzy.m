% PSO for CA_Fuzzy Edge Detection

% main.m, mpPSO.m, fit_ness.m, maskCA.m
% 10/10/2013 2013 Edge Detection çal??mas? tamamland?.
close all
%clear all
clc
%
% takes in a list of images with ground truths, performs boosting approach
% to generate a set of filters to solve the edge detection of the images
% saves the filter parametes in one file and the list of which filter
% solves which image
% ImageFilesPath = 'C:\Users\ajw4388\Documents\Thesis\Berkely_Segmentation_Set\BSDS500\data\images\test';
% GroundTruthFilesPath = 'C:\Users\ajw4388\Documents\Thesis\Berkely_Segmentation_Set\BSDS500\data\groundTruth\test';
% load('MatFileResults\cannySobelBDM_DefaultSettings_AllGT.mat');
ImageSaveFolderName = 'TestingFuzzyAddedImages'; % make this ahead of time
ImageSaveFolder = [pwd '\' ImageSaveFolderName];
mkdir(ImageSaveFolder);
load('CannySobelBDM\CannySobelBDMAddedImagesTrain.mat')
% load('CannySobelBDM.mat')%all image files and ground truths come from here to maintain consistancy
% addpath(ImageFilesPath,GroundTruthFilesPath);
% ImageFiles = dir(fullfile(ImageFilesPath, '*.jpg'));
% GroundTruthFiles = dir(fullfile(GroundTruthFilesPath, '*.mat'));

%
iteration =50;

    %this array of cells will contain: 1) the image,
    %                                  2) its ground truth,
    %                                  3) the index of the filter in the filter array, and its corrisponding BDM,
    %                                  4) the BDM of the fit from canny and sobel 
    %                                  5) Image Name
    AllImages = cell(size(CannySobelBDM,1),5);

    for i=1:size(CannySobelBDM,1)
    %      imFullName =ImageFiles(i).name(1:end-4);
         AllImages{i,1} = double(rgb2gray(CannySobelBDM(i).ImageFile));
         AllImages{i,2} = double(CannySobelBDM(i).GroundTruthFile);
         AllImages{i,5} = CannySobelBDM(i).ImageName;
         AllImages{i,6} = CannySobelBDM(i).ImageFile;
    end
    for x = 1:size(AllImages,1)
        BenchBDM = [CannySobelBDM(x).BDM_Sobel CannySobelBDM(x).BDM_Canny CannySobelBDM(x).BDM_Prewitt CannySobelBDM(x).BDM_Roberts CannySobelBDM(x).BDM_Log];
        AllImages{x,4} = min(BenchBDM);
%         if(CannySobelBDM(x).BDM_Sobel < CannySobelBDM(x).BDM_Canny)
%            AllImages{x,4} = CannySobelBDM(x).BDM_Sobel ;
%         else
%            AllImages{x,4} = CannySobelBDM(x).BDM_Canny ;
%         end

    end
    
    count = 1;
    AllFilters = cell(size(AllImages,1),1);
    
    % this is greedy and will need to be revisited
    for i=1:size(AllImages,1)
        %starting point for PSO: 1-> division offset 2-> fuzzy boundery 3-> CA rule
        parameters = [60 0.3 23;79 1 124; 105 0 321; 23 0.3 452;78 0.01 35;92 0.6 326;73 0.43 168;86 0.87 245; 112 0.54 410;124 0.67 203;
                  51 0.23 123;69 0.89 24; 101 0.34 121; 39 0.4 45;71 0.19 355;97 0.73 56;134 0.3 18;35 0.71 45;68 0.47 386;82 0.712 178;];
        %           imFullName =ImageFiles(1).name(1:end-4);
        %     im1 = imread(ImageFiles(1).name);
        size(parameters);
        c1 =2.01;% velocity modifier
        c2 = 2.01;% velocity modifier
        % [row,col] = size (im1);
        coef =[.73 c1 c2];% velocity modifier


         %can let run through all of them for times sake on early testing only
         %running until all are solved better than canny and sobel, this can be
         %a speaking point in the thesis
        if(isempty(AllImages{i,3}))
                imgGrey = AllImages{i,1};
                imgGT = AllImages{i,2};
                mkdir(ImageSaveFolderName,AllImages{i,5});

                [bestParameters, best_BDM, localPositions,localFitness ] = myFuzzyPSO(imgGrey, imgGT, coef, iteration, parameters);


                [bestPosition, bestCAEdgeImage] = fuzzy_fitness(imgGrey,imgGT, bestParameters); 
                imwrite(bestCAEdgeImage, strcat([ImageSaveFolder '\' AllImages{i,5} '\'],'bestCAEdgeImage.jpg'));
                %the trained filter must be paired with the filter it was
                %trained to

                

                AllImages{i,3}(end+1,:) = [count,bestPosition];


                %find a reduced set of filters which will solve the set
                for iter=1:length(AllImages)       

                        tempImgGrey =AllImages{iter,1};       
                        tempImgGT = AllImages{iter,2};
                        BDM = fuzzy_fitness(tempImgGrey,tempImgGT, bestParameters); 
                        %dont double count the Filter Trained in the current
                        %iteration
                        if(BDM < AllImages{iter,4} && iter ~= i)
                            AllImages{iter,3}(end+1,:) = [count,BDM];
                        end

                end

                close all;
                AllFilters{count} = bestParameters;
                count = count +1;
           
        end
     save(strcat([ImageSaveFolder '\' ['AllFilters' ] ]),'AllFilters'); %filters that solve images
     save(strcat([ImageSaveFolder '\' ['AllImages' ] ]),'AllImages'); % which filter sovles which image
   end

 
 save(strcat([ImageSaveFolder '\' ['AllFilters' ] ]),'AllFilters'); %filters that solve images
 save(strcat([ImageSaveFolder '\' ['AllImages' ] ]),'AllImages'); % which filter sovles which image
 
 
    
 
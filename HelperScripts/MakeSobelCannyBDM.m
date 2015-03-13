% make a quick comparison data set with default sobel and canny
ImageFilesPath = 'C:\Users\ajw4388\Documents\Thesis\Berkely_Segmentation_Set\BSDS500\data\images\AaronTestingNN';
GroundTruthFilesPath = 'C:\Users\ajw4388\Documents\Thesis\Berkely_Segmentation_Set\BSDS500\data\groundTruth\AaronTestingNNBusy';
addpath(ImageFilesPath,GroundTruthFilesPath);
ImageFiles = dir(fullfile(ImageFilesPath, '*.jpg'));
GroundTruthFiles = dir(fullfile(GroundTruthFilesPath, '*.mat'));


    
   minNumGT = 100;
 
  for i=1:length(ImageFiles)
            imFullName =ImageFiles(i).name(1:end-4);
            im = imread(ImageFiles(i).name);
            imgGrey =double(rgb2gray(im));
            load(GroundTruthFiles(i).name);

            if(minNumGT > length(groundTruth))
                minNumGT = length(groundTruth);
            end
            for whichGT = 1:length(groundTruth)
                % in the event that there is less ground truths in one file
                % than another
                

                 imgGT = double(groundTruth{whichGT}.Boundaries);
                 sobel_edge =edge(rgb2gray(imread(ImageFiles(i).name)),'sobel');
                 canny_edge =edge(rgb2gray(imread(ImageFiles(i).name)),'canny');
                 prewitt_edge =edge(rgb2gray(imread(ImageFiles(i).name)),'prewitt');
                 roberts_edge =edge(rgb2gray(imread(ImageFiles(i).name)),'roberts');
                 log_edge =edge(rgb2gray(imread(ImageFiles(i).name)),'log');
                 se=im2double(sobel_edge);
                 ce=im2double(canny_edge);
                 pe=im2double(prewitt_edge);
                 re=im2double(roberts_edge);
                 le=im2double(log_edge);
                 [val_sobel, dMap] = BDM(imgGT,se,'x', 2, 'euc');
                 [val_canny, dMap] = BDM(imgGT,ce,'x', 2, 'euc');
                 [val_prewitt, dMap] = BDM(imgGT,pe,'x', 2, 'euc');
                 [val_roberts, dMap] = BDM(imgGT,re,'x', 2, 'euc');
                 [val_log, dMap] = BDM(imgGT,le,'x', 2, 'euc');
                 CannySobelBDM(i,whichGT) = struct('ImageName',imFullName,'ImageFile', im,'GroundTruthFile',...
                     imgGT,'GroundTruthNumber',whichGT,...
                     'BDM_Sobel',val_sobel,'OutputImage_Sobel',sobel_edge,...
                     'BDM_Canny',val_canny,'OutputImage_Canny',canny_edge,...
                     'BDM_Prewitt',val_prewitt,'OutputImage_Prewitt',prewitt_edge,...
                     'BDM_Roberts',val_roberts,'OutputImage_Roberts',roberts_edge,...
                     'BDM_Log',val_log,'OutputImage_Log',log_edge);   
            end
           
      
  end
    save('CannySobelBDMTestingNNBusy','CannySobelBDM','-v7.3')

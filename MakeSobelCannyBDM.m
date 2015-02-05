% make a quick comparison data set with default sobel and canny
ImageFilesPath = 'C:\Users\ajw4388\Documents\Thesis\Berkely_Segmentation_Set\BSDS500\data\images\val';
GroundTruthFilesPath = 'C:\Users\ajw4388\Documents\Thesis\Berkely_Segmentation_Set\BSDS500\data\groundTruth\val';
addpath(ImageFilesPath,GroundTruthFilesPath);
ImageFiles = dir(fullfile(ImageFilesPath, '*.jpg'));
GroundTruthFiles = dir(fullfile(GroundTruthFilesPath, '*.mat'));


    
   
 
  for i=1:length(ImageFiles)
            imFullName =ImageFiles(i).name(1:end-4);
            im = imread(ImageFiles(i).name);
            imgGrey =double(rgb2gray(im));
            load(GroundTruthFiles(i).name);

            for whichGT = 1:length(groundTruth)
                % in the event that there is less ground truths in one file
                % than another
                

                 imgGT = double(groundTruth{whichGT}.Boundaries);
                 sobel_edge =edge(rgb2gray(imread(ImageFiles(i).name)),'sobel');
                 canny_edge =edge(rgb2gray(imread(ImageFiles(i).name)),'canny');
                 se=im2double(sobel_edge);
                 ce=im2double(canny_edge);
                 [val_sobel, dMap] = BDM(imgGT,se,'x', 2, 'euc');
                 [val_canny, dMap] = BDM(imgGT,ce,'x', 2, 'euc');
                 CannySobelBDM(i,whichGT) = struct('ImageName',imFullName,'ImageFile', im,'GroundTruthFile',...
                     imgGT,'GroundTruthNumber',whichGT,'BDM_Sobel',val_sobel,'BDM_Canny',val_canny,...
                     'OutputImage_Sobel',sobel_edge,'OutputImage_Canny',canny_edge);   
            end
           
      
  end
    save('CannySobelBDMTest','CannySobelBDM','-v7.3')

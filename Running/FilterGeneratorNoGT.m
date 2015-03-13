function [ResultingEdgeImage,BetterPerformance] = FilterGeneratorNoGT(ResultNN,inputDir,dirName)
%Non-fuzzy System
% takes the NN from the Non-fuzzy system and applies it to input images
% takes the File Folder with input images (only handles one folder at a
% time) must be .jpg images
% takes final save folder location
% 
%saves the resulting edge image to the save folder

ImageFilesPath = inputDir;
addpath(ImageFilesPath);
ImageFiles = dir(fullfile(ImageFilesPath, '*.jpg'));
    clear AllImages AllTargetsCell
    count = 1;
    clear AllImages AllTargetsCell names SobelEdgeImage SobelBDM CannyEdgeImage CannyBDM
    
    %read in all of the images and create the standard edge images for them
    for x = 1:size(ImageFiles,1)
        
        im = imread(ImageFiles(x).name);
        im = imresize(im,[481,481]);
        AllImages{count} = im;               
        names{count} = ImageFiles(x).name(1:end-4);               
        SobelEdgeImage{count} = edge(rgb2gray(im),'sobel');              
        CannyEdgeImage{count} = edge(rgb2gray(im),'canny');
        PrewittEdgeImage{count} = edge(rgb2gray(im),'prewitt');
        RobertsEdgeImage{count} = edge(rgb2gray(im),'roberts');
        LogEdgeImage{count} = edge(rgb2gray(im),'log');               
        count = count +1;
        
    end
    
    %extract the Image features for all of the images
    temp = FeatureExtractionFunc(AllImages);
    AllFeatures = temp{1}; 
    
    %set up the NN
    mVal = ResultNN.Mean;
    W = ResultNN.PCATransformationMatrix;
    meanMat = ones(size(AllFeatures'))*diag(mVal);
    net = ResultNN.NeuralNetwork;
    net.layers{2}.transferFcn = 'tansig';
    
    %Reduce the dimentionality of the feature set 
    ReducedFeatures =((AllFeatures'-meanMat)*W)';
    
    % get the filter index from the network
    output = net(ReducedFeatures);
    [~,tester] = max(output);
    output = tester;
    
    %for all of the images perform the edge detection with the selected 
    %filter and then display all edge images with GT and original
    figure(1);title('Edge Image Comparison');
    for x = 1:size(AllImages,2)
        Filter = bin2dec(num2str(output(:,x))');%get the filter which is binary incoded
        
        [EdgeImage] = Non_Fuzzy_Filtering(double(im2bw(rgb2gray(AllImages{x}),0.4)), Filter);
                
        subplot(3,3,[1:3]);imshow(AllImages{x});title(['Original Image ' names(x)]);
        subplot(3,3,4);imshow(EdgeImage);title(['Test']);
        subplot(3,3,5);imshow( SobelEdgeImage{x});title(['Sobel']);
        subplot(3,3,6);imshow( CannyEdgeImage{x});title(['Canny' ]);
        subplot(3,3,7);imshow( PrewittEdgeImage{x});title(['Prewitt']);
        subplot(3,3,8);imshow( RobertsEdgeImage{x});title(['Roberts' ]);
        subplot(3,3,9);imshow( LogEdgeImage{x});title(['LoG' ]);
        saveas(figure(1),strcat(dirName, '/', names{x}),'jpg')
        ResultingEdgeImage(x) = struct('EdgeImage', EdgeImage,...
            'Original',AllImages{x},'ImageName', names{x},...
            'SobelEdgeImage', SobelEdgeImage{x},...
            'CannyEdgeImage',CannyEdgeImage{x},...
            'PrewittEdgeImage',PrewittEdgeImage{x},...
            'RobertsEdgeImage',RobertsEdgeImage{x},...
            'LogEdgeImage',LogEdgeImage{x},...
            'Filter',Filter );
    end
    
    save([dirName '/_ResultingEdgeImages'], 'ResultingEdgeImage');
end


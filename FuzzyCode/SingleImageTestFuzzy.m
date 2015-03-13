%test a Single image for its edge detaction against a filter taken from a file location against its ground truth
%also taken from a file location, the ground truth is assumed to be stored
%in the Berkely Segmentation Database(BSD) format
figure(1);
filter = [66 0.53599 98]; % three argument filter for Fuzzy Filters
imshow(imread('C:\Users\ajw4388\Documents\Thesis\Berkely_Segmentation_Set\BSDS500\data\images\AaronTestingNN\227090.jpg'))
tempImgGrey = double(rgb2gray(imread('C:\Users\ajw4388\Documents\Thesis\Berkely_Segmentation_Set\BSDS500\data\images\AaronTestingNN\227090.jpg')));
load('C:\Users\ajw4388\Documents\Thesis\Berkely_Segmentation_Set\BSDS500\data\groundTruth\AaronTestingNNBusy\227090.mat')
for whichGT = 1:length(groundTruth)
    figure(2)
    imshow(groundTruth{whichGT}.Boundaries);
    tempImgGT = double(groundTruth{whichGT}.Boundaries);
    [BDM im] = fuzzy_fitness(tempImgGrey,tempImgGT,[66 0.53599 98]'); 
    Figure(3)
    imshow(im);
end



GroundTruthFilesPath = 'C:\Users\ajw4388\Documents\Thesis\Berkely_Segmentation_Set\BSDS500\data\groundTruth\AaronTestingNN';
SparseGTFilePath = 'C:\Users\ajw4388\Documents\Thesis\Berkely_Segmentation_Set\BSDS500\data\groundTruth\AaronTestingNNSparse';
mkdir(SparseGTFilePath);
BusyGTFilePath = 'C:\Users\ajw4388\Documents\Thesis\Berkely_Segmentation_Set\BSDS500\data\groundTruth\AaronTestingNNBusy';
mkdir(BusyGTFilePath);
addpath(GroundTruthFilesPath);
GroundTruthFiles = dir(fullfile(GroundTruthFilesPath, '*.mat'));

for i = 1:length(GroundTruthFiles)
     load(GroundTruthFiles(i).name);
     numedgePixels = zeros(length(groundTruth),1);
     for whichGT = 1:length(groundTruth)
        imgGT = double(groundTruth{whichGT}.Boundaries);
        numedgePixels(whichGT) = sum(sum(imgGT));
     end
     groundTruthCopy = groundTruth;
     groundTruth = groundTruthCopy(find(numedgePixels == max(numedgePixels),1));
     save([BusyGTFilePath '\' GroundTruthFiles(i).name],'groundTruth');
     groundTruth = groundTruthCopy(find(numedgePixels == min(numedgePixels),1));
     save([SparseGTFilePath '\' GroundTruthFiles(i).name],'groundTruth');
end
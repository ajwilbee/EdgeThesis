for x = 1: size(CannySobelBDM,1)
    imwrite(CannySobelBDM(x,1).ImageFile, ['ForPaper\' CannySobelBDM(x,1).ImageName '.jpg']);
    imwrite(CannySobelBDM(x,1).GroundTruthFile, ['ForPaper\' CannySobelBDM(x,1).ImageName 'GT.jpg']);
end
    
    
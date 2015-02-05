BDM = zeros(length(ResultingEdgeImage),1);
Sobel = zeros(length(ResultingEdgeImage),1);
Canny = zeros(length(ResultingEdgeImage),1);
Filters = zeros(length(ResultingEdgeImage),1);
    for y = 1: length(ResultingEdgeImage)
      
           BDM(y) = ResultingEdgeImage(y).BDM;

           Sobel(y) = ResultingEdgeImage(y).SobelBDM;
       
           Canny(y) = ResultingEdgeImage(y).CannyBDM;
           
           Filters(y) = ResultingEdgeImage(y).Filter;

    end

out = [BDM Sobel Canny Filters]; 
csvwrite('ResultPlot.csv',out);

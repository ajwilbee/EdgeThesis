%within the set of filters discovered each solves the image better than
 %the sobel or canny, however it is possible that of the filters discovered
 %the set can be reduced while still allowing for all of the filters to
 %perform better than the canny an the sobel, it would be interresting to
 %see what the difference in performance is when this reduction is made
 %both prior to matching through the NN and after the matching has occured
 
 % question which filter to I qualify as working the best? the ones that
 % solve the largest number 

% takes AllImages and determines what the smallest set of filters is which
% will still solve all images

count = 1
for x = 1:size(AllImages,1)
   
    if(size(AllImages{x,3},1) == 1)
        FinalList(count) = AllImages{x,3}(1,1);
    end
    
    
end
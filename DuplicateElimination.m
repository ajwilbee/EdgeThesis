%map the duplicates to the lowest filter number occurance and then
%eliminater all others while maintaining the indexing

Mapping = 0;
for x = 1:length(AllFilters)
    count2 = 1;
    for y = x+1:length(AllFilters)
        if(AllFilters{x} == AllFilters{y})
            Mapping(x,count2) = y;
            count2 = count2+1;
        end
    end
end
for a =1: size(Mapping,1)
    temp = Mapping(a,:);
    temp(temp == 0) = [];
    for b =1: length(temp)
        for x = 1:size(AllImages,1)
            
                 if(AllImages{x,3}(1) == temp(b))
                     AllImages{x,3}(1) = a;
                 end
        
        end
    end
end
FilterUsed = zeros(length(AllFilters),1);
for x = 1:size(AllImages,1)
    
        
          FilterUsed(AllImages{x,3}(1)) =    1;
         
   
end
%sort the filters so that the gaps are removed and pushed to the bottom use
%the index I to keep the consistancy with the AllImages array
[B I] = sort(FilterUsed,'descend');
for x = 1:size(AllImages,1)

    AllImages{x,3}(1) = find(I == AllImages{x,3}(1),1);

end

AllFilters(~FilterUsed) = [];
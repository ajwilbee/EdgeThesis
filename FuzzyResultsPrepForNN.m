for x =1: size(AllImages,1)
    temp = AllImages{x,1};
   AllImages{x,1} =AllFilters(temp);
   AllImages{x,2} =AllFilters(temp);
end
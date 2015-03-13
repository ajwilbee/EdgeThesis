function [t_Img]=Non_Fuzzy_Filtering(imgGrey,parameters)

n=size(imgGrey,1);
m=size(imgGrey,2);
image=zeros(n,m);
MaskCA = getMaskCA(parameters(end,1));
    for i=1:n
        for j=1:m
            if (j+2<=m) && (i+2<=n)
                mask=imgGrey(i:i+2,j:j+2);
                rule_nbd=sum(sum(abs(MaskCA.*(mask-mask(2,2)))));
                %% Fuzzy CA
                image(i+1,j+1) = mod(rule_nbd,2);               
            end
        end
    end
        t_Img=image;
        
end

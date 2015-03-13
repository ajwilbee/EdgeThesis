function [t_Img]= fuzzy_filtering(imgGrey,parameters)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
n=size(imgGrey,1);
m=size(imgGrey,2);
image=zeros(n,m);
MaskCA = getMaskCA(parameters(end,1));
    for i=1:n
        for j=1:m
            if ((j+2<=m) && (i+2<=n))

                mask=imgGrey(i:i+2,j:j+2);
                rule_nbd=sum(sum(abs(MaskCA.*(mask-mask(2,2)))));
                %% Fuzzy CA
                mf = rule_nbd/(rule_nbd+parameters(1,1));
                if mf >parameters(2,1)
                    image(i+1,j+1)=1;
                else
                    image(i+1,j+1)=0;
                end
                

            end
        end
    end
        t_Img=image;
   

end

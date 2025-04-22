function [P_s,flag_P_s,LM,d]=find_P_s(P_c,image_hor)
flag_P_s=0;
d=-1;
LM=double(image_hor(image_hor==P_c | image_hor==P_c-d)==P_c-d);
for P_s = P_c+1 : 255 
    H_P_s=sum(image_hor==P_s);
    if H_P_s-sum(image_hor(1:16)==P_s) >= length(LM)+32
        flag_P_s=1; 
        break
    end
end
end
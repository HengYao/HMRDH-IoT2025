function [P_c,flag_P_c,LM,d]=find_P_c(P_s,image_hor)
flag_P_c=0;
d=1;
H_P_s=sum(image_hor==P_s);
for P_c = P_s+1 : 255 
    LM=double(image_hor(image_hor==P_c | image_hor==P_c-d)==P_c-d);
    if H_P_s-sum(image_hor(1:16)==P_s) >= length(LM)+32
        flag_P_c=1; 
        break
    end
end
end

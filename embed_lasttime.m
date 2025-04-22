function [image_hor,payload_total,iteration,embedding_capacity_left] = embed_lasttime(P_s_previous,P_c_previous,P_s_lasttime,P_c_lasttime,ref_image_hor,actual_payload,payload_total,iteration,payload_length_last)

P_s=P_s_previous;
P_c=P_c_previous;
first_16_pixels=ref_image_hor(1:16,iteration);
original_16_lsb=mod(first_16_pixels,2);

if P_s < P_c %RHS
    d = 1;
else %LHS
    d = -1;
end    

%Exclude first 16 pixels from histogram shifting
image_hor = ref_image_hor(17:end,iteration);
H_P_s=sum(image_hor==P_s);
LM=(image_hor(image_hor==P_c | image_hor==P_c-d)==P_c-d);
payload_total(end-payload_length_last+1:end)=[];
if length(payload_total) < length(actual_payload)
    payload_left_over=length(actual_payload)-length(payload_total);
    if payload_left_over < H_P_s-length(LM)-32
        synthetic_payload =randi([0,1],H_P_s-length(LM)-32-payload_left_over,1);
        payload = [actual_payload(length(payload_total)+1:end); synthetic_payload];
    else
        payload = actual_payload(length(payload_total)+1:length(payload_total)+H_P_s-length(LM)-32);
    end
else
    payload =randi([0,1],H_P_s-length(LM)-32,1);
end
message=[LM ; de2bi(P_s_lasttime,8)'; de2bi(P_c_lasttime,8)';original_16_lsb;payload];
message_whole=zeros(length(image_hor),1);
message_whole(image_hor==P_s)=message;

image_hor(image_hor==P_c-d)=image_hor(image_hor==P_c-d)+d;

%Shift P_s's neighbors towards P_c
if d == 1
    image_hor(image_hor > P_s & image_hor < P_c)=image_hor(image_hor > P_s & image_hor < P_c)+d; %RHS
else
    image_hor(image_hor < P_s & image_hor > P_c)=image_hor(image_hor < P_s & image_hor > P_c)+d; %LHS
end

%Embed P_s
image_hor(image_hor==P_s & message_whole)=image_hor(image_hor==P_s & message_whole)+d;

%Append back the first 16 pixels and replace 16 lsbs with P_s and P_c 
image_hor=[bitxor(bitxor(first_16_pixels,mod(first_16_pixels,2)),[de2bi(P_s,8)'; de2bi(P_c,8)']) ;image_hor];
payload_total=[payload_total; payload];
embedding_capacity_left=length(payload_total)-length(actual_payload);

end
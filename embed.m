function [image_hor,payload_total,iteration,ref_image_hor,payload_length_last] = embed(P_s,P_c,P_s_previous,P_c_previous,image_hor,LM,d,actual_payload,payload_total,iteration,ref_image_hor,payload_length_last)

% Function: perform one iteration of embedding

H_P_s=sum(image_hor==P_s);
if length(payload_total) < length(actual_payload)
    payload_left_over=length(actual_payload)-length(payload_total);
    if payload_left_over < H_P_s-length(LM)-16
        synthetic_payload =randi([0,1],H_P_s-length(LM)-16-payload_left_over,1);
        payload = [actual_payload(length(payload_total)+1:end); synthetic_payload];
    else
        payload = actual_payload(length(payload_total)+1:length(payload_total)+H_P_s-length(LM)-16);
    end
else
    payload =randi([0,1],H_P_s-length(LM)-16,1);
end
payload_length_last=length(payload);
payload_total=[payload_total; payload];
message=[LM ; de2bi(P_s_previous,8)'; de2bi(P_c_previous,8)';payload]; 
iteration=iteration+1;
ref_image_hor(:,iteration)=image_hor;
message_whole=zeros(length(image_hor),1);
message_whole(image_hor==P_s)=message;

%Combine P_c with its neighbor
image_hor(image_hor==P_c-d)=image_hor(image_hor==P_c-d)+d;

%Shift P_s's neighbors towards P_c
if d == 1
image_hor(image_hor > P_s & image_hor < P_c)=image_hor(image_hor > P_s & image_hor < P_c)+d; %RHS
else
image_hor(image_hor < P_s & image_hor > P_c)=image_hor(image_hor < P_s & image_hor > P_c)+d; %LHS
end

%Embed P_s
image_hor(image_hor==P_s & message_whole)=image_hor(image_hor==P_s & message_whole)+d;

end
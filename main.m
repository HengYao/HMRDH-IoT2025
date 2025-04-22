function main

image=double(im2gray(imread('Kodak images/kodim04_org.png')));

iteration_max=1000;
max_single_try=5; % maximum number of attempts allowed for a single bin
diff=0.50E-03; % error threshold
payload_length=0; % number of bits to be embedded
payload=randi([0,1],payload_length,1);

%Embedding
[rdh_image,embedding_capacity_left,ref_hist,iteration,embedTime]=hmrdh(diff,image,payload,iteration_max,max_single_try);
if embedding_capacity_left < 0 
    disp('Failed embedding')
else
    disp(['Can embed ' num2str(embedding_capacity_left) ' bits more (estimated)'])
end

%Recovery
[payload_rec, re_image,recoverTime] = hmrdh_recovery(rdh_image);
if isequal(re_image,image)
    disp('Original image recovered')
else
    disp('Failed to recover the original image')
end

if isequal(payload_rec,payload)
    disp('Payload recovered')
else
    disp('Failed to recover the payload')
end

close all

mse_value=calculate_mse(rdh_image,ref_hist);
psnr_value=calculate_psnr(image, rdh_image);
embedding_rate=calculate_embeddingcapacity(image,embedding_capacity_left);

figure(1)
imshow(uint8(image))
figure(2)
imshow(uint8(rdh_image))
figure(3)
imhist(uint8(image));
figure(4)
imhist(uint8(rdh_image));

end
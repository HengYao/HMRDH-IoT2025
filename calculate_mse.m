function Rmse_value = calculate_mse(rdh_image,ref_hist)
[counts2, x2] = imhist(uint8(rdh_image));   
total_pixels2 = numel(rdh_image); 
normalized_counts2 = counts2 / total_pixels2; 

ref_hist = ref_hist';
mse_value = sum((normalized_counts2 - ref_hist).^2) / length(normalized_counts2);
Rmse_value = sqrt(mse_value);
disp('RMSE value between output image and reference histogram:');
disp(Rmse_value); 
end
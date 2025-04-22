function [mse] = calculate_compare_mse(image_hor,ref_hist,totalCounts)
image_all=image_hor';
image_hist = histcounts(image_all, 0:256); 
image_hist = image_hist / totalCounts; 
mse = sum((image_hist - ref_hist).^2) / length(image_hist);
end
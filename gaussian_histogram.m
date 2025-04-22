function H = gaussian_histogram(mu, sigma)  
bin_count = 256;  
range = [0, 255];  
bin_width = (range(2) - range(1) + 1) / bin_count; 
H = zeros(1, bin_count);  

for i = 1:bin_count  
    bin_center = range(1) + (i - 0.5) * bin_width; 
    H(i) = normpdf(bin_center, mu, sigma);  
end  
H = H / sum(H);  
end
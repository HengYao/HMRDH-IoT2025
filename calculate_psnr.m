function psnr_value=calculate_psnr(image_ref, image_tar)
mse = mean((image_ref(:) - image_tar(:)).^2);
max_value = max(image_ref(:));
psnr_value = 10 * log10(max_value^2 / mse);
disp('PSNR value:');
disp(psnr_value);
end
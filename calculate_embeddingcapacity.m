function embedding_rate=calculate_embeddingcapacity(image,embedding_capacity_left)
totalPixels = numel(image);
embedding_rate=embedding_capacity_left/totalPixels;
disp('embedding_rate(bpp):');
disp(embedding_rate);
end

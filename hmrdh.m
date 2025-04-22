function [rdh_image,embedding_capacity_left,ref_hist,iteration,embedTime]=hmrdh(diff,image, actual_payload, iteration_max,max_single_try)

image_size=size(image);
rng(0);
ref_image_hor = zeros(image_size(1)*image_size(2),iteration_max);
ref_image_hor(:,1) = reshape(image,image_size(1)*image_size(2),1);
image_hor=ref_image_hor(:,1);

payload_length_max=2*ceil(log2(image_size(1)*image_size(2)+1));
actual_payload=[de2bi(length(actual_payload),payload_length_max)'; actual_payload];
payload_total=[];

P_s_previous=0;
P_c_previous=0;
payload_length_last=0;
iteration=0;
single_try=0;

[counts,~] = histcounts(double(image(:)), 0:256);
totalCounts = sum(counts);  
ori_hist = counts / totalCounts; 
ref_hist=gaussian_histogram(128,50);
%ref_hist=uniform_histogram();
mse_current=calculate_compare_mse(image_hor,ref_hist,totalCounts); 

% Iterative single-bin adjustment
tic
current_bin=0;  
while current_bin<=254
    image_all=image_hor';
    image_hist = histcounts(image_all, 0:256); 
    image_hist = image_hist / totalCounts; 
    difference = image_hist - ref_hist;  
    
    if iteration==iteration_max
        break
    end

    if difference(current_bin+1)>diff % If current_bin is higher than target value, perform Ps splitting
        P_s=current_bin;
        [P_c,flag_P_c,LM,d]=find_P_c(P_s,image_hor);
        if flag_P_c ==1 % Suitable corresponding Pc found
            
            % Save current state for potential rollback
            mse_last=mse_current;
            payload_total_previous=payload_total;
            
            % Perform one iteration
            [image_hor,payload_total,iteration,ref_image_hor,payload_length_last] = embed(P_s,P_c,P_s_previous,P_c_previous,image_hor,LM,d,actual_payload,payload_total,iteration,ref_image_hor,payload_length_last);
            single_try=single_try+1;
            mse_current = calculate_compare_mse(image_hor,ref_hist,totalCounts);

            % Compare MSE values
            if mse_last<=mse_current % If MSE increases, rollback this embed
                image_hor = ref_image_hor(1:end,iteration);
                iteration=iteration-1;
                mse_current=mse_last;
                payload_total=payload_total_previous;
            else % If MSE decreases, keep this embed
                P_s_lasttime=P_s_previous;
                P_c_lasttime=P_c_previous;
                P_s_previous=P_s;
                P_c_previous=P_c;
            end

        else % No suitable corresponding Pc found, proceed to next current_bin
            current_bin=current_bin+1;
            single_try=0;
            continue 
        end

    elseif abs(image_hist(current_bin+1) - ref_hist(current_bin+1))<=diff
        current_bin=current_bin+1;
        single_try=0;
        continue    

    elseif difference(current_bin+1)<(0-diff) % If current_bin is below the target value, perform Pc merging
        P_c=current_bin;
        [P_s,flag_P_s,LM,d]=find_P_s(P_c,image_hor);
        if flag_P_s ==1 
            [image_hor,payload_total,iteration,ref_image_hor,payload_length_last] = embed(P_s,P_c,P_s_previous,P_c_previous,image_hor,LM,d,actual_payload,payload_total,iteration,ref_image_hor,payload_length_last);
            mse_last=mse_current;
            payload_total_previous=payload_total;
            single_try=single_try+1;
            mse_current = calculate_compare_mse(image_hor,ref_hist,totalCounts);

            if mse_last<=mse_current
                image_hor = ref_image_hor(1:end,iteration);
                iteration=iteration-1;
                mse_current=mse_last;
                payload_total=payload_total_previous;
            else
                P_s_lasttime=P_s_previous;
                P_c_lasttime=P_c_previous;
                P_s_previous=P_s;
                P_c_previous=P_c;
            end

        else
            current_bin=current_bin+1;
            single_try=0;
            continue 
        end
    end

    % Stop condition check
    [counts,~] = histcounts(double(image(:)), 0:256);
    ori_hist = counts / totalCounts; 
    if abs(ori_hist(current_bin+1) - ref_hist(current_bin+1))<diff % Error is small enough
        current_bin=current_bin+1;
        single_try=0;
        continue 
    end
    if single_try == max_single_try % Reached max iteration count for current bin
        current_bin=current_bin+1;
        single_try=0;
        continue 
    end
end

% Last iteration
[image_hor,payload_total,iteration,embedding_capacity_left] = embed_lasttime(P_s_previous,P_c_previous,P_s_lasttime,P_c_lasttime,ref_image_hor,actual_payload,payload_total,iteration,payload_length_last);
rdh_image=reshape(image_hor,image_size(1),image_size(2));

embedTime = toc; 
disp(['embeding time: ', num2str(embedTime), ' seconds']);
end

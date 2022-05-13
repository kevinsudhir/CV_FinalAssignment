% Loading the provided data set
load Brain.mat

% Initilization of score arrays
similarity_score = zeros(6,1,'double');
ssim_array = zeros(6, 1, 'double');
dice_score = zeros(6, 1, 'double');

% Display set for image output
figure(); colormap gray; axis equal; axis off;

%Traverse over all the images and labels from data set
for i=1:10
    image = T1(:,:,i); % Reading the ith image
    l = label(:,:,i);  % Reading the ith label
    
    % Creating final mask to store each segmented mask
    final_mask = zeros(size(l));
    
    % Use manual thresholding to create binary image
    image = mat2gray(image);
    level = graythresh(image);
    outer = imbinarize(image,level);
    % Sort connected components by size 
    [v, n] = bwlabel(outer, 8); 
    flag = sum(bsxfun(@eq,v(:),1:n));
    % Finding and assigning the 2 biggest contours
    [v2, n2] = maxk(flag, 2);
    t1 = n2(1);
    t2 = n2(2);
    inval = v == t1;
    % Filling the holes in inner mask
    fill_imask = imfill(inval, 'holes');
    
    % Outer ring mask creation
    out_imask = image;
    outval = fill_imask == 1;
    out_imask(outval) = 0;
    
    % Find the manual value for the outer ring mask
    % and update outer ring and outer mask to final mask
    out_imask = imadjust(out_imask);
    out_rmask = out_imask > 2.352900e-01; % Value for the outer ring mask
    outer_vals = out_rmask == 1;
    final_mask(outer_vals)=1;
    subplot(6,1,2); % Plotting mask 1
    imagesc(out_rmask);
    caption = sprintf('Mask 1');
    title(caption, 'FontSize', 8);

    % Manually creating background mask from outer ring mask 
    bg_mask = imfill(out_rmask, 'holes');
    bg_mask = imcomplement(bg_mask);
    l_values = bg_mask == 1;
    final_mask(l_values)=0;
    lindex=2;
    subplot(6,1,1); % Plotting mask 0
    imagesc(bg_mask);
    caption = sprintf('Mask 0 - Background mask');
    title(caption, 'FontSize', 8);
    
    % Manually creating inner ring and inner mask from outer ring mask 
    inner_rmask = imcomplement(out_rmask);
    inner_rmask = imsubtract(inner_rmask,fill_imask);
    inner_rmask = imsubtract(inner_rmask,double(bg_mask));
    inner_vals = inner_rmask == 1;
    final_mask(inner_vals)=lindex;
    lindex = lindex+1;
    subplot(6,1,3); % Plotting mask 2
    imagesc(inner_rmask);
    caption = sprintf('Mask 2');
    title(caption, 'FontSize', 8);
    
    % Creating 3 different masks for inner components
    f = strel('disk', 5);
    in_imask = image;
    in_vals = imerode(fill_imask == 0, f);
    in_imask(in_vals) = 0;
        
    % Manual calculation for generating mask class 3(A)
    Xmin = min(in_imask(:));
    Xmax = max(in_imask(:));
    if isequal(Xmax,Xmin)
        in_imask = 0*in_imask;
    else
        in_imask = (in_imask - Xmin) ./ (Xmax - Xmin);
    end
    
    % Find the manual value for the 3(A) inner ring mask
    % Generating Mask class 3(A) using inner mask and outer mask
    temp_imask = imcomplement(in_imask);
    l3a_vals = temp_imask > 4.588200e-01; % Value for the 3(A)
    img_temp = imsubtract(l3a_vals,bg_mask);
    temp_mask = zeros((size(l)));
    vals1 = img_temp==1;
    temp_mask(vals1) = 1;
    vals2 = img_temp == -1;
    temp_mask(vals2) = 0;
    l3a_vals = temp_mask == 1;
    img_temp2 = imsubtract(l3a_vals,out_rmask);
    temp_mask2 = zeros((size(l)));
    vals11 = img_temp2==1;
    temp_mask2(vals11) = 1;
    vals22 = img_temp2 == -1;
    temp_mask2(vals22) = 0;
    l3a_vals = temp_mask2 == 1;
    img_temp3 = imsubtract(l3a_vals,inner_vals);
    temp_mask3 = zeros((size(l)));
    vals111 = img_temp3==1;
    temp_mask3(vals111) = 1;
    vals222 = img_temp3 == -1;
    temp_mask3(vals222) = 0;
    l3a_vals = temp_mask3 == 1;
    final_mask(l3a_vals) = lindex;
    lindex = lindex+1;
    subplot(6,1,4); % Plotting mask 3
    imagesc(l3a_vals);
    caption = sprintf('Mask 3');
    title(caption, 'FontSize', 8);
    
    % Find the manual value for the 3(B) inner ring mask
    % Generating mask class 3(B)
    l3b_vals = in_imask > 7.137300e-01; % Value for the 3(B)
    l3b_vals = imcomplement(l3b_vals);
    img_temp = imsubtract(l3b_vals,imcomplement(fill_imask));
    temp_mask = zeros((size(l)));
    vals1 = img_temp==1;
    temp_mask(vals1) = 1;
    vals2 = img_temp == -1;
    temp_mask(vals2) = 1;
    temp_mask = imsubtract(temp_mask,double(l3a_vals));
    l3b_vals = temp_mask == 1;
    final_mask(l3b_vals) = lindex;
    lindex = lindex+1;
    subplot(6,1,5); % Plotting mask 4
    imagesc(l3b_vals);
    caption = sprintf('Mask 4');
    title(caption, 'FontSize', 8);
    
    % Find the manual value for the 3(C) inner ring mask
    % Generating Mask class 3(C)
    l3c_vals = in_imask > 7.764700e-01; % Value for the 3(C)
    final_mask(l3c_vals) = lindex;
    lindex = lindex+1;
    subplot(6,1,6); % Plotting mask 5
    imagesc(l3c_vals);
    caption = sprintf('Mask 5');
    title(caption, 'FontSize', 8);

    % Calculate metrics for each mask
    similarity = jaccard(categorical(l), categorical(final_mask));
    similarity_score = similarity_score + similarity;
    dice_val = dice(categorical(l), categorical(final_mask));
    dice_score = dice_score + dice_val;
    ssim_score = get_ssim_scores(l, final_mask);
    ssim_array = ssim_array + ssim_score;   
end

similarity_score = similarity_score / 10;
ssim_array = ssim_array / 10;
dice_score = dice_score / 10;
% Compute mean of all three calculated scores
mean_score = (similarity_score + ssim_array + dice_score) / 3;
meanval = mean(mean_score);

% Plotting final result mask
figure();colormap gray; axis equal; axis off;
imagesc(final_mask);
caption = sprintf('Final Result Mask');
title(caption, 'FontSize', 14);
% Plotting ground truth
figure();colormap gray; axis equal; axis off;
imagesc(l);
caption = sprintf('Ground Truth');
title(caption, 'FontSize', 14);
    
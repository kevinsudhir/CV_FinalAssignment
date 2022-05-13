% Loading the provided data set
load Brain.mat

% Display set for image output
figure(); colormap gray; axis equal; axis off;

% Initilization of score arrays
similarity_score = zeros(6,1,'double');
ssim_array = zeros(6, 1, 'double');
dice_score = zeros(6, 1, 'double');

%Traverse over all the images and labels from data set
for i=1:10
    
    image = T1(:,:,i); % Reading the ith image    
    l = label(:,:,i); % Reading the ith label
    
    % Creating final mask to store each segmented mask
    final_mask = zeros(size(l));
    lindex=0;
    
    % Use Multi thresholding to create binary image
    t = multithresh(image, 1);
    outer = imquantize(image,t);
    portion_mask = outer == 2;    
    % Sort connected components by size 
    [v, n] = bwlabel(portion_mask, 8); 
    flag = sum(bsxfun(@eq,v(:),1:n));
    % Finding and assigning the 2 biggest contours
    [v2, n2] = maxk(flag, 2); 
    t1 = n2(1);
    t2 = n2(2);
    % Creating active contour image for outer mask
    mask = zeros(size(l));
    mask(25:end-25,25:end-25) = 1;
    img_ac = activecontour(image,mask,100);
    inval = v == t1;
    % Deriving the background mask by using image from active contour
    mask_background = imcomplement(imfill(img_ac, 'holes'));
    f = strel('disk', 9);
    % Filling the remaining holes in inner mask
    fill_imask = imclose(inval, f);
    subplot(6,1,1); % Plotting mask 0
    imagesc(mask_background);
    caption = sprintf('Mask 0 - Background mask');
    title(caption, 'FontSize', 8);
    
    % Background mask creation and updating it to final mask
    l_values = mask_background == 1;
    final_mask(l_values)=lindex;
    lindex=lindex+1;
    
    % Outer ring mask creation
    out_imask = image;
    outval = fill_imask == 1;
    out_imask(outval) = 0;
    t = multithresh(out_imask, 2); % Image mask conversion into 2 classes
    v = imquantize(out_imask, t);  
    
    % Updating outer ring and outer mask to final mask
    out_rmask = v == 1;
    out_rmask = imcomplement(out_rmask);
    outer_vals = out_rmask == 1;
    final_mask(outer_vals)=lindex;
    lindex = lindex+1;
    subplot(6,1,2); % Plotting mask 1
    imagesc(out_rmask);
    caption = sprintf('Mask 1');
    title(caption, 'FontSize', 8);
    
    % Updating inner ring and inner mask to final mask
    inner_rmask = zeros((size(l)));
    inner_ring_vals = v == 2;
    inner_rmask(v == 1) = 1;
    bg_vals = mask_background == 1;
    inner_rmask(bg_vals) = 0;
    inner_vals = fill_imask ==1;
    inner_rmask(inner_vals) = 0;
    inner_mask_vals = inner_rmask == 1;
    final_mask(inner_mask_vals)=lindex;
    lindex = lindex+1;    
    subplot(6,1,3); % Plotting mask 2
    imagesc(inner_rmask);
    caption = sprintf('Mask 2');
    title(caption, 'FontSize', 8);
   
    % Creating masks for inner components
    f = strel('disk', 8);
    in_imask = image;
    in_vals = imerode(fill_imask == 0, f);
    in_imask(in_vals) = 0;
    % Segmenting inner mask using Multi class Otsu Thresholding
    t = multithresh(in_imask, 3); % Into 3 classes
    v_in = imquantize(in_imask, t);
    
    % Mask class 3(A)
    l3a_vals = v_in == 2;
    final_mask(l3a_vals) = lindex;
    lindex = lindex+1;
    subplot(6,1,4); % Plotting mask 3
    imagesc(l3a_vals);
    caption = sprintf('Mask 3');
    title(caption, 'FontSize', 8);
    
    % Mask class 3(B)
    l3b_vals = v_in == 3;
    final_mask(l3b_vals) = lindex;
    lindex = lindex+1;
    subplot(6,1,5); % Plotting mask 4
    imagesc(l3b_vals);
    caption = sprintf('Mask 4');
    title(caption, 'FontSize', 8);
    
    % Mask class 3(C)
    l3c_vals = v_in == 4;
    final_mask(l3c_vals) = lindex;
    lindex = lindex+1;
    subplot(6,1,6); % Plotting mask 5
    imagesc(l3c_vals);
    caption = sprintf('Mask 5');
    title(caption, 'FontSize', 8);
  
    % Calculate metrics for each score
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
%Compute mean of all three calculated scores
mean_score = (similarity_score + ssim_array + dice_score) / 3;
mean_val = mean(mean_score);

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

% Loading the provided data set
load Brain.mat

image = T1; % Reading the image
l = label; % Reading the label

% Creating final mask to store each segmented mask
final_mask = zeros(size(l));
lindex = 0;

% Use Multi thresholding to create binary image
t = multithresh(image, 1);
outer = imquantize(image, t);
p_mask = zeros(size(outer));
t_vals = outer == 2;
p_mask(t_vals) = 1;
v = bwlabeln(p_mask); % Get components that are connected
in_rmask = zeros(size(outer));
invals = v == 3;
in_rmask(invals) = 1;
% Creating active contour image for outer mask
mask = zeros(size(l));
mask(25:end-25,25:end-25) = 1;
img_ac = activecontour(image,mask,100);
% Deriving the background mask by using image from active contour in 3D
mask_background = imfill3d(img_ac);
% Filling the remaining holes in inner mask in 3D
fill_imask = imfill3d(in_rmask);

% Background mask creation and updating it to final mask
maskbg = zeros((size(l)));
l_values = mask_background == 0;
maskbg(l_values) = 1;
final_mask(l_values) = lindex;
lindex = lindex+1;

% Outer ring 3D mask creation
out_mask = image;
outvals = fill_imask == 1;
out_mask(outvals) = 0;
t = multithresh(out_mask, 2); % Image mask conversion into 2 classes
v = imquantize(out_mask, t);  

% Updating outer ring and outer mask to final mask
out_rmask = zeros((size(l)));
outval = v == 1;
out_rmask(outval) = 1;
out_rmask = imcomplement(out_rmask);
outer_rvals = out_rmask == 1;
final_mask(outer_rvals)=lindex;
lindex = lindex+1;

% Updating inner ring and inner mask to final mask
in_rmask = zeros((size(l)));
in_rvals = v == 2;
in_rmask(outval) = 1;
l_values = maskbg == 1;
in_rmask(l_values) = 0;
invals = fill_imask ==1;
in_rmask(invals) = 0;
in_maskvals = in_rmask == 1;
final_mask(in_maskvals)=lindex;
lindex = lindex+1;

% Creating masks for inner components in 3D
f = strel('disk', 8);
in_imask = image;
invals = imdilate(fill_imask, f)==0;
in_imask(invals) = 0;
% Segmenting inner mask using Multi class Otsu Thresholding
t = multithresh(in_imask, 3); % Into 3 classes
v_in = imquantize(in_imask, t);   

% Mask class 3(A)
l3a_mask = zeros((size(l)));
l3a_vals = v_in == 2;
l3a_mask(l3a_vals) = 1;
final_mask(l3a_vals) = lindex;
lindex = lindex+1;

% Mask class 3(B)
l3b_mask = zeros((size(l)));
l3b_vals = v_in == 3;
l3b_mask(l3b_vals) = 1;
final_mask(l3b_vals) = lindex;
lindex = lindex+1;

% Mask class 3(C)
l3c_mask = zeros((size(l)));
l3c_vals = v_in == 4;
l3c_mask(l3c_vals) = 1;
l3c_vals = l3c_mask == 1;
final_mask(l3c_vals) = lindex;
lindex = lindex+1;

% Calculate metrics for each score
similarity = jaccard(categorical(l), categorical(final_mask));
ssim_score = get_ssim_scores(l, final_mask);
dice_score = dice(categorical(l), categorical(final_mask));
%Compute mean of all three calculated scores
mean_score = (similarity + dice_score + ssim_score) / 3;
mean_val = mean(mean_score);

% Plotting final result mask
figure();
volshow(final_mask);
figure();
volshow(l);

% Function to fill image along all the three dimensions
function f3=imfill3d(f3)
    for i=1:3
        for j=1:size(f3,3)
            f3(:,:,j)=imfill(f3(:,:,j),'holes');
        end
    end
end

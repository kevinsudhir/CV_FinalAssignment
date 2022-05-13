load Brain.mat

image = T1;
l = label;

final_mask = zeros(size(l));
lindex = 0;

t = multithresh(image, 1);
outer = imquantize(image, t);
p_mask = zeros(size(outer));
t_vals = outer == 2;
p_mask(t_vals) = 1;
v = bwlabeln(p_mask);
in_rmask = zeros(size(outer));
invals = v == 3;
in_rmask(invals) = 1;
mask = zeros(size(l));
mask(25:end-25,25:end-25) = 1;
img_ac = activecontour(image,mask,100);
mask_background = imfill3d(img_ac);
fill_imask = imfill3d(in_rmask);

maskbg = zeros((size(l)));
l_values = mask_background == 0;
maskbg(l_values) = 1;
final_mask(l_values) = lindex;
lindex = lindex+1;

out_mask = image;
outvals = fill_imask == 1;
out_mask(outvals) = 0;
t = multithresh(out_mask, 2);
v = imquantize(out_mask, t);  

out_rmask = zeros((size(l)));
outval = v == 1;
out_rmask(outval) = 1;
out_rmask = imcomplement(out_rmask);
outer_rvals = out_rmask == 1;
final_mask(outer_rvals)=lindex;
lindex = lindex+1;

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

f = strel('disk', 8);
in_imask = image;
invals = imdilate(fill_imask, f)==0;
in_imask(invals) = 0;
t = multithresh(in_imask, 3);
v_in = imquantize(in_imask, t);   

l4_mask = zeros((size(l)));
l4_vals = v_in == 2;
l4_mask(l4_vals) = 1;
final_mask(l4_vals) = lindex;
lindex = lindex+1;

l5_mask = zeros((size(l)));
l5_vals = v_in == 3;
l5_mask(l5_vals) = 1;
final_mask(l5_vals) = lindex;
lindex = lindex+1;

l6_mask = zeros((size(l)));
l6_vals = v_in == 4;
l6_mask(l6_vals) = 1;
l6_vals = l6_mask == 1;
final_mask(l6_vals) = lindex;
lindex = lindex+1;

figure();
volshow(final_mask);
figure();
volshow(l);

function f3=imfill3d(f3)
    for i=1:3
        for j=1:size(f3,3)
            f3(:,:,j)=imfill(f3(:,:,j),'holes');
        end
    end
end

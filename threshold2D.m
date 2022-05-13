load Brain.mat

figure(); colormap gray; axis equal; axis off;

for i=1:10

    image = T1(:,:,i);
    l = label(:,:,i);

    final_mask = zeros(size(l));
    lindex=0;
    
    t = multithresh(image, 1);
    outer = imquantize(image,t);
    portion_mask = outer == 2;
    [v, n] = bwlabel(portion_mask, 8); 
    flag = sum(bsxfun(@eq,v(:),1:n));
    [v2, n2] = maxk(flag, 2);
    t1 = n2(1);
    t2 = n2(2);
    mask = zeros(size(l));
    mask(25:end-25,25:end-25) = 1;
    img_ac = activecontour(image,mask,100);
    inval = v == t1;
    mask_background = imcomplement(imfill(img_ac, 'holes'));
    f = strel('disk', 3);
    fill_imask = imclose(inval, f);
    subplot(6,1,1);
    imagesc(mask_background);

    l_values = mask_background == 1;
    final_mask(l_values)=lindex;
    lindex=lindex+1;

    out_imask = image;
    outval = fill_imask == 1;
    out_imask(outval) = 0;
    t = multithresh(out_imask, 2);
    v = imquantize(out_imask, t);  
    
    out_rmask = v == 1;
    out_rmask = imcomplement(out_rmask);
    outer_vals = out_rmask == 1;
    final_mask(outer_vals)=lindex;
    lindex = lindex+1;
    subplot(6,1,2);
    imagesc(out_rmask);

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
    subplot(6,1,3);
    imagesc(inner_rmask);
   
    f = strel('disk', 8);
    in_imask = image;
    in_vals = imerode(fill_imask == 0, f);
    in_imask(in_vals) = 0;
    t = multithresh(in_imask, 3);
    v_in = imquantize(in_imask, t);
    
    l4_vals = v_in == 2;
    final_mask(l4_vals) = lindex;
    lindex = lindex+1;
    subplot(6,1,4);
    imagesc(l4_vals);
    
    l5_vals = v_in == 3;
    final_mask(l5_vals) = lindex;
    lindex = lindex+1;
    subplot(6,1,5);
    imagesc(l5_vals);
    
    l6_vals = v_in == 4;
    final_mask(l6_vals) = lindex;
    lindex = lindex+1;
    subplot(6,1,6);
    imagesc(l6_vals);

end  

figure();colormap gray; axis equal; axis off;
subplot(1,2,1);
imagesc(l);
subplot(1,2,2);
imagesc(final_mask);
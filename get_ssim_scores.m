% Function to calcute ssim scores (Structural Similatiry)
function values=get_ssim_scores(grount_truth, l)
    values = zeros(6,1,'double');
    for i=0:5
        grount_truth_mask = zeros((size(grount_truth)));
        grount_truth_vals = grount_truth == i;
        grount_truth_mask(grount_truth_vals) = 1;

        mask = zeros((size(grount_truth)));
        vals = l == i;
        mask(vals) = 1;
        [ssim_values, ~] = ssim(grount_truth_mask, mask);
        values(i+1) = values(i+1) + ssim_values;
    end
end
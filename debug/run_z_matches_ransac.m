W3 = find_wafer_in_secs(secs, 'S2-W003');
W4 = find_wafer_in_secs(secs, 'S2-W004');
for s = [W3 W4]
    secs{s} = ransac_section_z(secs, s);
    imwrite_section_plot(secs{s}, 'z', 'z');
    imwrite_z_residuals(secs, s, 'z');
end

secs = propagate_tforms_through_secs(secs, W4(end));
filename = 'wafers_piriform/150611_S2-W001-W006_ransac_z.mat';
save(filename, 'secs', '-v7.3');
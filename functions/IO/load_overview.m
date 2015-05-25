function sec = load_overview(sec)
%LOAD_OVERVIEW Loads the overview image of a section at 1x scale.
% Usage:
%   sec = load_overview(sec)

load_time = tic;

overview_path = get_overview_path(sec);

sec.overview.img = imread(overview_path);
sec.overview.path = overview_path;
sec.overview.size = size(sec.overview.img); % get unscaled size
sec.overview.alignments.initial.tform = affine2d();
sec.overview.alignments.initial.rel_to_sec = sec.num;

fprintf('Loaded overview (1x) in %s. [%.2fs]\n', sec.name, toc(load_time))

end


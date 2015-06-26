clear params;

% CHANGE get_path_info REGEX when changing datasets!

%% Defaults: Rough XY alignment
% General
params.xy.overwrite = true; % throws error if section is already XY aligned
params.xy.skip_tiles = [];

% [rough_align_xy] Rough alignment
% Overview registration
params.rough_xy.rel_to = 'initial';
params.rough_xy.align_to_overview = true;
% ratio of pixel actual dimensions
params.rough_xy.overview_to_tile_resolution_ratio = 0.07; % piriform
% params.rough_xy.overview_to_tile_resolution_ratio = 0.05; % zfish
params.rough_xy.tile_prescale = 1;
params.rough_xy.overview_prescale = 1;
params.rough_xy.overview_scale = 0.78;
params.rough_xy.expected_overlap = 0.06;
params.rough_xy.overview_cropping = [0.25 0.25 0.5 0.5]; % piriform
% params.rough_xy.overview_cropping = [0.38 0.25 0.40 0.66]; % zfish
params.rough_xy.median_filter_radius = 0;

% Tile to overview SURF parameters (no good justification)
params.rough_xy.SURF_MetricThreshold = 1000;
params.rough_xy.SURF_NumOctaves = 4;
params.rough_xy.SURF_NumScaleLevels = 3;

%% Defaults: XY alignment

% [detect_features] Feature detection
params.xy.features.detection_scale = 1.0;
params.xy.features.min_overlap_area = 0.02;
params.xy.features.SURF.MetricThreshold = 11000; % for full res tiles

% [match_xy] Matching: NNR
params.xy.matching.NNR.MaxRatio = 0.6;
params.xy.matching.NNR.MatchThreshold = 1.0;

% [match_xy] Matching: Outlier filtering
params.xy.matching.filter_method = 'geomedian'; % 'geomedian', 'gmm' or 'none'
params.xy.matching.filter_fallback = 'none';
params.xy.matching.keep_outliers = true;
params.xy.matching.geomedian.cutoff = '1.25x';
params.xy.matching.GMM.inlier_cluster = 'smallest_var';
params.xy.matching.GMM.warning = 'error';
params.xy.matching.GMM.Replicates = 5;

% [align_xy] Alignment
params.xy.align.fixed_tile = 1;

% Quality control checks
params.xy.max_match_error = 100; % avg error after matching
params.xy.max_aligned_error = 5; % avg error after alignment
params.xy.ignore_error = true; % still throws warning if true

%% params: Z alignment
% General
params.z.overwrite = true; % throws error if section is already Z aligned
params.z.rel_to = -1; % relative section to align to
params.z.scale = 0.125;
params.z.SURF.MetricThreshold = 2000;

% [detect_features] Feature detection (0.125x)
params.z.features.scale = 0.125;
params.z.features.SURF.MetricThreshold = 2000;

% Matching
params.z.matching_mode = 'auto'; % 'auto' or 'manual'

% [match_z] Matching: NNR
params.z.matching.NNR.MaxRatio = 0.6;
params.z.matching.NNR.MatchThreshold = 1.0;

% [match_z] Matching: Outlier filtering
params.z.matching.filter_method = 'gmm'; % 'geomedian', 'gmm' or 'none'
params.z.matching.filter_fallback = 'geomedian';
params.z.matching.keep_outliers = true;
params.z.matching.geomedian.cutoff = '1.25x';
params.z.matching.GMM.inlier_cluster = 'geomedian';
params.z.matching.GMM.warning = 'off';
params.z.matching.GMM.Replicates = 5;

% Alignment
params.z.alignment_method = 'cpd'; % 'lsq', 'cpd' or 'fixed'

% Quality control checks
params.z.max_match_error = 1000; % avg error after matching
params.z.max_aligned_error = 50; % avg error after alignment
params.z.ignore_error = true; % only throws warning if true

%% Initialize parameters with params
params = repmat(params, max(sec_nums), 1);
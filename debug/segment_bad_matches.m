function [stats, definitely_bad, possibly_bad] = segment_bad_matches(matches, tformsA, tformsB, definitely_bad_threshold, possibly_bad_threshold)
% Provide two segments of bad matches, based on displacement thresholds
%
% Inputs:
%   matches: matches struct (i.e. sec.xy_matches)
%   tformsA: set of tforms corresponding to tiles in matches.A
%   tformsB: set of tforms corresponding to tiles in matches.B
%   definitely_bad_threshold: lower bound of definitely_bad matches, upper
%   bound of possibly_bad_matches
%   possibly_bad_threshold: lower bound of possibly_bad_matches
% Outputs:
%   stats: stats table on all matches
%   definitely_bad: matches struct containing matches above
%   definitely_bad_threshold
%   possibly_bad: matches struct containing matches between
%   possibly_bad_threshold and definitely_bad_threshold
%

if nargin < 4
    if strcmp(matches.match_type, 'xy')
        definitely_bad_threshold = 20;
        possibly_bad_threshold = 5;    
    else
        definitely_bad_threshold = 120;
        possibly_bad_threshold = 30;
    end
end

stats = calculate_matches_stats(matches, tformsA, tformsB);

definitely_bad = stats(stats.dist > definitely_bad_threshold, :);
possibly_bad = stats(stats.dist > possibly_bad_threshold & stats.dist < definitely_bad_threshold, :);

% rownorm2(tform.transformPointsForward(z_matches.B.global_points) - z_matches.A.global_points)

disp(['No of total matches: ' num2str(length(stats))]);
disp(['No of definitely bad matches: ' num2str(length(definitely_bad))]);
disp(['No of possibly bad matches: ' num2str(length(possibly_bad))]);
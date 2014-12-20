function matches = combine_secs_matches(secs)
% Combine all match pairs into one large matches table
%
% Inputs:
%   secs: cell array of sec structs; must have xy_matches & z_matches
%   attributes, as well as tforms in sec.alignments.z.
%
% Outputs:
%   matches: table of match pairs


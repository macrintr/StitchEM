function secs = propagate_tforms_through_secs(secs, s)
% Propagate a tform through an entire stack, starting with the xy tform

% Propagate through to the end of the secs
for s = s:length(secs)
    secs = update_sec_tforms(secs, s);
end
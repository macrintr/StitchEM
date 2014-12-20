clearvars;
load('/home/tmacrina/StitchEM/trash/S2-W007_xy_aligned_recropped.mat')
secsB = secs;
load('/home/tmacrina/StitchEM/trash/S2-W007_xy_aligned.mat')

load('/home/tmacrina/StitchEM/S2-W007_Sec7_xy_aligned.mat')
sec.alignments.xy = align_xy(sec);
secs{sec.num} = sec;
load('/home/tmacrina/StitchEM/S2-W007_Sec8_xy_aligned.mat')
sec.alignments.xy = align_xy(sec);
secs{sec.num} = sec;
load('/home/tmacrina/StitchEM/S2-W007_Sec14_xy_aligned.mat')
sec.alignments.xy = align_xy(sec);
secs{sec.num} = sec;
load('/home/tmacrina/StitchEM/S2-W007_Sec24_xy_aligned.mat')
sec.alignments.xy = align_xy(sec);
secs{sec.num} = sec;
load('/home/tmacrina/StitchEM/S2-W007_Sec27_xy_aligned.mat')
sec.alignments.xy = align_xy(sec);
secs{sec.num} = sec;
load('/home/tmacrina/StitchEM/S2-W007_Sec47_xy_aligned.mat')
sec.alignments.xy = align_xy(sec);
secs{sec.num} = sec;
load('/home/tmacrina/StitchEM/S2-W007_Sec49_xy_aligned.mat')
sec.alignments.xy = align_xy(sec);
secs{sec.num} = sec;

for i=1:length(secs)
    if i < 51
        secs{i}.alignments.rough_xy.meta.cropping_percentages = [0.25 0.25 0.5 0.5];
    else
        secs{i} = secsB{i};
        secs{i}.alignments.rough_xy.meta.cropping_percentages = [0.3300 0.1600 0.5700 0.5700];
    end
end

for i=1:length(secs)
    if ~isfield(secs{i}.alignments, 'xy')
        i
    end
end

% filename = sprintf('%s_xy_aligned.mat', secs{1}.wafer);
% save(filename, 'secs', '-v7.3');
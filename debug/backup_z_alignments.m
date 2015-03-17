function secs = backup_z_alignments(secs)
% Save all the original z alignments to old_z alignments

for i=1:10
    secs{i}.alignments.old_z = secs{i}.alignments.z;
end
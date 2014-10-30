pre_error = [];
post_error = [];
for n=1:sum(~cellfun('isempty',secs))
    pre_error(end+1) = secs{n}.alignments.xy.meta.avg_prior_error;
    post_error(end+1) = secs{n}.alignments.xy.meta.avg_post_error;
end
n = 1:sum(~cellfun('isempty',secs));
figure
plot(n, post_error, '-og', n, pre_error, '-or')
legend('post', 'pre')
ylabel('XY Error (pixels)')
x_name = sprintf('Sections within %s', secs{1}.name);
xlabel(x_name)

%% rough xy alignment
for i=start:finish
    
end

%% xy alignment
for i=start:finish
    
end

%% rough overview z alignment
for i=start:finish
    % Load overview for the sections
    secs{i} = load_overview(secs{i});
    if isempty(secs{i-1}.overview.img)
        secs{i-1} = load_overview(secs{i-1});
    end
    
    secB = align_overview_rough_z(secs{i-1}, secs{i});
    
    imwrite_overview_pair(secs{i-1}, secs{i}, 'initial', 'rough_z', 'overview_rough_z')
    secs{i-1} = imclear(secs{i-1});
end

%% rough z alignment
for i=start:finish
    secB = align_rough_z(secB);
end

%% z alignment
for i=start:finish
    
end
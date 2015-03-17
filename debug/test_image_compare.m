n = length(secs);
no_alignment = cell(n, 16);
z_alignment = cell(n, 16);
identity_alignment = cell(n, 16);

for j=1:n-1
    parfor i=1:16
        tileA = imread(secs{j}.tile_paths{i});
        tileB = imread(secs{j+1}.tile_paths{i});
        tileA = adapthisteq(tileA);
        tileB = adapthisteq(tileB);
        
        % No transform applied
        tformA = secs{j}.alignments.initial.tforms{i};
        tformB = secs{j+1}.alignments.initial.tforms{i};
        disp(['No tform Sec ' num2str(j) ' Tile ' num2str(i)]);
        [composite, percentage] = image_compare(tileA, tileB, tformA, tformB);
        
        no_alignment{j, i} = percentage;
        
        % z transform applied
        tformA = secs{j}.alignments.z.tforms{i};
        tformB = secs{j+1}.alignments.z.tforms{i};
        disp(['Z tform Sec ' num2str(j) ' Tile ' num2str(i)]);
        [composite, percentage] = image_compare(tileA, tileB, tformA, tformB);

        z_alignment{j, i} = percentage;
        
        disp(['Identity Sec ' num2str(j) ' Tile ' num2str(i)]);
        [composite, percentage] = image_compare(tileA, tileA, tformA, tformA);
        
        identity_alignment{j, i} = percentage;
        
        if no_alignment{j, i} > z_alignment{j, i}
            disp([num2str(j) '_' num2str(i) ' failure']);
        end
    end
end
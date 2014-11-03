% Obtains a bounding box around each object-like class instance in the
% image
%
% Args:
%   imgObjectLabels - HxW label map. 0 indicates a missing label.
%   imgInstances - HxW instance map.
%   allowedLabels - Kx1 array of class labels get bounding boxes for.
%   percentage - The percentage of growth of the bounding box around the
%   object in terms of the size of the original bounding box
%
% Returns:
%   bbxs - cell structure containing each bounding box 

function [ bbxs ] = get_bbxs( imgObjectLabels, imgInstances, allowedLabels, percentage)
    if nargin < 4
        percentage = 0.2;
    end
    
    bbxs = {};
    bbx_count = 1;
    
    assert(numel(imgInstances) == numel(imgObjectLabels));
    
    imSize = size(imgInstances);
    labels = unique(imgObjectLabels);
    labels = intersect(labels, allowedLabels);
    
    for i = 1:size(labels)
        label = labels(i);
        l_pixs = imgObjectLabels == label;                                 %obtain the logical indices
        instances = unique(imgInstances(l_pixs));                          %obtain instance labels
        
        %loop to get the bbx for each instance
        for j = 1:size(instances)
            inst = l_pixs & imgInstances==j;                               %the object instance in the image (logical index)
            nonzero_idxs = find(inst ~= 0);   
            
            [I,J] = ind2sub(imSize,nonzero_idxs);                          %get pixel coords for nonzero entries
            
            l1 = min(I);                                                   %get the upper left and lower right
            l2 = min(J);                                                   %corner values
            r1 = max(I);
            r2 = max(J);
            w = (r1-l1);
            h = (r2-l2);
            
            % This is the old way which doesn't account for the center of the object
%             l1 = max(l1-w*percentage/2,2);
%             l2 = max(l2-h*percentage/2,2);
%             r1 = min(r1 + w*percentage/2, imSize(1));
%             r2 = min(r2 + w*percentage/2, imSize(2));
            %bbxs{bbx_count}.bb = [l1,l2,r1,r2];                            %store the corners of the bounding box
            %bbxs{bbx_count}.center = [(l1+r1)/2, (l2+r2)/2];  
            
            bbxs{bbx_count}.center = [mean(I), mean(J)];   %compute the center. This will be learned upon
            bbxs{bbx_count}.w = min(w + w*percentage,imSize(1)-l1);        %width adjusted
            bbxs{bbx_count}.h = min(h + h*percentage, imSize(2)-l2);       %height adjusted
            
            l1 = max(bbxs{bbx_count}.center(1) - bbxs{bbx_count}.w/2,2);   %readjust the points to be focused around the center
            l2 = max(bbxs{bbx_count}.center(2) - bbxs{bbx_count}.h/2,2);   
            r1 = min(bbxs{bbx_count}.center(1) + bbxs{bbx_count}.w/2, imSize(1));
            r2 = min(bbxs{bbx_count}.center(2) + bbxs{bbx_count}.h/2, imSize(2));
            
            bbxs{bbx_count}.bb = [l1,l2,r1,r2];                            %store the corners of the bounding box
            bbx_count = bbx_count + 1;
        end
    end
    
    % plot the labels and their bounding boxes
%     figure;
%     imagesc(imgObjectLabels);
%     colorbar;
%     for j=1:bbx_count-1
%         hold on
%         bb = bbxs{j};
%         rectangle('Position',[bb.bb(2),bb.bb(1),bb.h,bb.w],'EdgeColor','w','LineWidth',2 );
%         viscircles([bb.center(2),bb.center(1)], 3);
%     end

end


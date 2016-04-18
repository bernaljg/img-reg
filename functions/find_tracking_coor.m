%Created by: Bernal Jimenez
% 03/17/2016


%Finds tracking coordinates for all NMJs in each movie

function [tracking_coors] = find_tracking_coor(reader,roi_props,max_frame,max_frame_num,n_frames,n_nmjs)

    tracking_coors = cell(n_nmjs,1);
    
    %Loops through NMJs
    for nmjNum = 1:n_nmjs
        

        bbox = find_bounding_box(roi_props,nmjNum);
        
        refFrameCrop = crop_ref_frame(max_frame,bbox);
        
        trackingCoords=zeros(n_frames,4);
        trackingCoords(max_frame_num,:) = bbox;
        
        minOverlap=numel(refFrameCrop)/1.2;
	
        bbox_ref_frame = bbox;
    
	%Forward pass for tracking
    for qq =max_frame_num+1:n_frames
        
	    thisFrame = bfGetPlane(reader, qq);
	    thisFramePadded = padarray(thisFrame,[100 100],mean(thisFrame(:)));

	    thisFrame = thisFramePadded(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3));
	    thisFrame=imadjust(thisFrame);
	    thisFrame=enhanceContrastForAffine(thisFrame);
        
	    c = normxcorr2_general((thisFrame),(refFrameCrop),minOverlap);
                
	    [~, imax] = max(abs(c(:)));
	    [ypeak, xpeak] = ind2sub(size(c),imax(1));
	    corr_offset = [(xpeak-size(refFrameCrop,2)) (ypeak-size(refFrameCrop,1))];

    %                 c = normxcorr2(thisFrame(:,:,1),lastFrame(:,:,1));


	    bbox(2)=bbox(2)- corr_offset(2);
	    bbox(1)=bbox(1)- corr_offset(1);

	    trackingCoords(qq,:) = bbox;
	     
	    disp(['Tracking NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   
    end

        bbox=bbox_ref_frame;

	%Backward pass for tracking
	for qq =max_frame_num-1:-1:1
  
	    thisFrame = bfGetPlane(reader, qq);
	    thisFramePadded = padarray(thisFrame,[100 100],mean(thisFrame(:)));

	    thisFrame = thisFramePadded(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3));
	    thisFrame=imadjust(thisFrame);
	    thisFrame=enhanceContrastForAffine(thisFrame);
        
	    c = normxcorr2_general((thisFrame),(refFrameCrop),minOverlap);

	    [~, imax] = max(abs(c(:)));
	    [ypeak, xpeak] = ind2sub(size(c),imax(1));
	    corr_offset = [(xpeak-size(refFrameCrop,2)) (ypeak-size(refFrameCrop,1))];

	    bbox(2)=bbox(2)- corr_offset(2);
	    bbox(1)=bbox(1)- corr_offset(1);

	    trackingCoords(qq,:) = bbox;
	    disp(['Tracking NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   

    	end
        
    tracking_coors{nmjNum,1} = trackingCoords;   
        
    end

end

function [bbox] = find_bounding_box(roi_props,nmjNum)

        regProps = roi_props{nmjNum};
	xInds = regProps.PixelList(:,1);
	yInds = regProps.PixelList(:,2);
	bbox = [min(regProps.PixelList(:,1)) min(regProps.PixelList(:,2)) max(regProps.PixelList(:,1))-min(regProps.PixelList(:,1)) max(regProps.PixelList(:,2))-min(regProps.PixelList(:,2))];

end

% Crops the reference frame using the bounding box and enhances contrast

function [refFrameCrop] = crop_ref_frame(max_frame,bbox)

        ref_crop = (max_frame(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3)));
        refFrameCrop = enhanceContrastForAffine(ref_crop);

end




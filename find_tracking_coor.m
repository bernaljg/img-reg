%Created by: Bernal Jimenez
% 03/17/2016


function [bbox] = find_bounding_box(roi_props)

        regProps = roi_props{nmjNum};
	xInds = regProps.PixelList(:,1);
	yInds = regProps.PixelList(:,2);
	bbox = [min(regProps.PixelList(:,1)) min(regProps.PixelList(:,2)) max(regProps.PixelList(:,1))-min(regProps.PixelList(:,1)) max(regProps.PixelList(:,2))-min(regProps.PixelList(:,2))];

end

% Crops the reference frame using the bounding box and enhances contrast

function [ref_frame_crop] = crop_ref_frame(max_frame,bbox)

        ref_crop = (max_frame(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3)));
        ref_frame_crop = enhanceContrastForAffine(firstFrame);

end



%Finds tracking coordinates for all NMJs in each movie

function [tracking_coors] = find_tracking_coor(reader,roi_props,max_frame,max_frame_num,n_frames,n_nmjs)

    tracking_coors = cell(nmjs,1)
    
    %Loops through NMJs
    parfor nmjNum = 1:n_nmjs
        

        bbox = find_bounding_box(roi_props)
	
	ref_frame_crop = crop_ref_frame(max_frame,bbox)

        trackingCoords=zeros(n_frames,4);
        trackingCoords(max_frame_num,:) = bbox;
        
	minOverlap=numel(ref_frame_crop)/1.2;
	
	%Forward pass for tracking
        for qq =max_frame_num+1:n_frames

	    thisFrame = bfGetPlane(reader, qq);
	    thisFramePadded = padarray(thisFrame,[100 100],mean(thisFrame(:)));

	    thisFrame = thisFramePadded(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3));
	    thisFrame=imadjust(thisFrame);
	    thisFrame=enhanceContrastForAffine(thisFrame);

	    c = normxcorr2_general((thisFrame),(ref_frame_crop),minOverlap);
	    [~, imax] = max(abs(c(:)));
	    [ypeak, xpeak] = ind2sub(size(c),imax(1));
	    corr_offset = [(xpeak-size(ref_frame_crop,2)) (ypeak-size(firstFrame2ref,1))];

    %                 c = normxcorr2(thisFrame(:,:,1),lastFrame(:,:,1));


	    bbox(2)=bbox(2)- corr_offset(2);
	    bbox(1)=bbox(1)- corr_offset(1);

	    trackingCoords(qq,:) = bbox;
	     
	    disp(['Tracking NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   
	end

        bbox=bboxStore;

	%Backward pass for tracking
	for qq =max_frame_num-1:-1:1
	    thisFrame = bfGetPlane(reader, qq);
	    thisFramePadded = padarray(thisFrame,[100 100],mean(thisFrame(:)));

	    thisFrame = thisFramePadded(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3));
	    thisFrame=imadjust(thisFrame);
	    thisFrame=enhanceContrastForAffine(thisFrame);

	    c = normxcorr2_general((thisFrame),(ref_frame_crop),minOverlap);
	    [~, imax] = max(abs(c(:)));
	    [ypeak, xpeak] = ind2sub(size(c),imax(1));
	    corr_offset = [(xpeak-size(ref_frame_crop,2)) (ypeak-size(firstFrame2ref,1))];

	    bbox(2)=bbox(2)- corr_offset(2);
	    bbox(1)=bbox(1)- corr_offset(1);

	    trackingCoords(qq,:) = bbox;
	    disp(['Tracking NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   

    	end
        
        
    tracking_coors{nmjNum,1} = trackingCoords;   
        
end




% Smooths Tracking Coordinates, Adds Padding and Saves Coordinates for all NMJs

function [smooth_tracking_coors,track] = save_smooth_coors(reader,trackingCoordinates,nFrames,maxFrameNum,FileNameApp)
    
    for nmjNum = 1:nNmjs
    
    	trackingCoords=trackingCoordinates{nmjNum,1};   
        tcoord1 = trackingCoords(:,1);
        tcoord2 = trackingCoords(:,2);
        trackSmoothFact = 10;
        tcoord1s = round(smooth(tcoord1,trackSmoothFact));
        tcoord2s = round(smooth(tcoord2,trackSmoothFact));
        trackingCoordsSmoothed = [tcoord1s tcoord2s trackingCoords(:,3) trackingCoords(:,4)];
        
	clear track
               
        track=zeros(trackingCoordsSmoothed(1,4)+1,trackingCoordsSmoothed(1,3)+1,nFrames,'uint16');

        for qq = 1:nFrames
            thisFrame = bfGetPlane(reader, qq);
            thisFramePadded = padarray(thisFrame,[100 100],mean(thisFrame(:)));

            track(:,:,qq)=(thisFramePadded(trackingCoordsSmoothed(qq,2):trackingCoordsSmoothed(qq,2)+trackingCoordsSmoothed(qq,4),trackingCoordsSmoothed(qq,1):trackingCoordsSmoothed(qq,1)+trackingCoordsSmoothed(qq,3)));
        end
        
        thisfilename = strcat(FileNameApp,'_registerNMJ','_',num2str(nmjNum),'.mat');
        save(thisfilename,'trackingCoords','trackingCoordsSmoothed','track','maxFrameNum','-v7.3')
        
	clear track trackingCoordsSmoothed trackingCoords

    end
	
end

%Created by: Bernal Jimenez
% 03/17/2016


% Smooths Tracking Coordinates, Adds Padding and Saves Coordinates for all NMJs

function [] = save_smooth_coors(reader,trackingCoordinates,nFrames,maxFrameNum,directory,FileNameApp,nNmjs)
    
    for nmjNum = 1:nNmjs
    
    	trackingCoords=trackingCoordinates{nmjNum,1};   
        tcoord1 = trackingCoords(:,1);
        tcoord2 = trackingCoords(:,2);
        trackSmoothFact = 10;
        tcoord1s = round(smooth(tcoord1,trackSmoothFact));
        tcoord2s = round(smooth(tcoord2,trackSmoothFact));
        trackingCoordsSmoothed = [tcoord1s tcoord2s trackingCoords(:,3) trackingCoords(:,4)];
        
	clear trackedMov
               
        trackedMov = zeros(trackingCoordsSmoothed(1,4)+1,trackingCoordsSmoothed(1,3)+1,nFrames,'uint16');

        for qq = 1:nFrames
            thisFrame = bfGetPlane(reader, qq);
            thisFramePadded = padarray(thisFrame,[100 100],mean(thisFrame(:)));

            trackedMov(:,:,qq)=(thisFramePadded(trackingCoordsSmoothed(qq,2):trackingCoordsSmoothed(qq,2)+trackingCoordsSmoothed(qq,4),trackingCoordsSmoothed(qq,1):trackingCoordsSmoothed(qq,1)+trackingCoordsSmoothed(qq,3)));
        end
       	
       	nmjMovie = trackedMov;

        thisfilename = strcat(FileNameApp,'_registerNMJ','_',num2str(nmjNum),'.mat');
        track_dir = fullfile(directory, 'track')
        mkdir(track_dir)
        save([track_dir '/' thisfilename],'trackingCoords','trackingCoordsSmoothed','trackedMov','nmjMovie','maxFrameNum','-v7.3');
        
	clear trackedMov trackingCoordsSmoothed trackingCoords

    end

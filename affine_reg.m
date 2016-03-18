% Created by: Bernal Jimenez
% 03/17/2016


function [tracked_nmjs] = load_tracked_nmjs(nNmjs,trackedFileNames)

    tracked_nmjs = cell(nNmjs,1);
    for trackmovieNum = 1:nNmjs   
        load(trackedFileNames(trackmovieNum).name,'tracked_mov','trackingCoords')
        tracked_nmjs{trackmovieNum,1}=track_mov;
        clear tracked_mov
    end
    
end

function [affineTransforms] = find_affine_transf(roiFiles, tracked_nmjs)

    load(roiFiles(movieNum).name)

    affineTransforms = cell(nNmjs,1);
    
    parfor nmjNum = 1:nNmjs
        disp(['Starting affine NMJ #: ',num2str(nmjNum)])
        tracked_nmj = tracked_nmjs{nmjNum,1};

        refFrameNorm = tracked_nmj(:,:,maxFrameNum);
        frameIn1 = imadjust(refFrameNorm);
        background = imopen(frameIn1,strel('disk',25));
        frameIn = frameIn1 - background;
        frameIn = imadjust(frameIn);
        frameIn = wiener2(frameIn,[15 15]);
        gthresh = graythresh(frameIn);
        refFrame = enhanceContrastForAffine(refFrameNorm);

        [optimizer, ~] = imregconfig('multimodal');
        metric = registration.metric.MattesMutualInformation;
        optimizer.MaximumIterations = 100;
        optimizer.InitialRadius = (6.250000e-03)/60;
        optimizer.Epsilon= 1.5e-6;
        optimizer.GrowthFactor = 1.05;  

        tfAffine = cell(nFrames,1);
        tfAffine{maxFrameNum,1}=affine2d([1 0 0;0 1 0;0 0 1]); 
        
        scaleThresh = 0.45;
        distTreshX = round(size(refFrame,2)/3);
        distTreshY = round(size(refFrame,1)/3);
	
	% Forward Affine Transformation
        for qq =maxFrameNum+1:nFrames    
        
            movingFrame = enhanceContrastForAffine(tracked_nmj(:,:,qq));
            movingFrame = imhistmatch(movingFrame,refFrame);
            movingFrame = wiener2(movingFrame,[10 10]);

            prevTformAff=tfAffine{qq-1}.T;       

            if prevTformAff(1,1)<scaleThresh || prevTformAff(2,2)<scaleThresh 
		    prevTformAff(1,1)=1;
		    prevTformAff(2,2)=1;    
            end
            
            if prevTformAff(3,1)>distTreshX || prevTformAff(3,2)>distTreshY 
		    prevTformAff(3,1)=0;
		    prevTformAff(3,2)=0;    
            end
            
            prevTformAff=affine2d(prevTformAff);
            tfAffine{qq,1} = imregtform(movingFrame,refFrame,'affine',optimizer,metric,'InitialTransformation',prevTformAff); 
          
             disp(['Affine NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   

        end
	
	% Backward Affine Tranformation
        for qq =maxFrameNum-1:-1:1
                
      	    movingFrame = enhanceContrastForAffine(tracked_nmj(:,:,qq));
            movingFrame = imhistmatch(movingFrame,refFrame);
            movingFrame = wiener2(movingFrame,[10 10]);
            
            prevTformAff=tfAffine{qq+1}.T;       

            if prevTformAff(1,1)<scaleThresh || prevTformAff(2,2)<scaleThresh 
		    prevTformAff(1,1)=1;
		    prevTformAff(2,2)=1;    
            end
            
            if prevTformAff(3,1)>distTreshX || prevTformAff(3,2)>distTreshY 
		    prevTformAff(3,1)=0;
		    prevTformAff(3,2)=0;    
            end
            
            prevTformAff=affine2d(prevTformAff);
            tfAffine{qq,1} = imregtform(movingFrame,refFrame,'affine',optimizer,metric,'InitialTransformation',prevTformAff);

        disp(['Affine NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   


        end

    affineTransforms{nmjNum,1}= tfAffine;
    end % parfor loop end

end

function [t1s,t2s,s1s,s2s,sh1s,sh2s] = smooth_affine(tfAffine,nFrames)

        for tfNum = 1:nFrames
            t1(tfNum,1) = tfAffine{tfNum}.T(3,1);
            t2(tfNum,1) = tfAffine{tfNum}.T(3,2);
            s1(tfNum,1) = tfAffine{tfNum}.T(1,1);
            s2(tfNum,1) = tfAffine{tfNum}.T(2,2);
            sh1(tfNum,1) = tfAffine{tfNum}.T(1,2);
            sh2(tfNum,1) = tfAffine{tfNum}.T(2,1);
        end

        smoothFactor = 15;
        t1s = smooth(t1,smoothFactor);
        t2s = smooth(t2,smoothFactor);
        s1s = smooth(s1,smoothFactor);
        s2s = smooth(s2,smoothFactor);
        sh1s =  smooth(sh1,smoothFactor);
        sh2s = smooth(sh2,smoothFactor);

end

function [] = save_affine_mov(affineTransforms,tracked_nmjs,trackedFileNames,maxFrameNum,nFrames,nNmjs)

    for nmjNum = 1:nNmjs
        tfAffine = affineTransforms{nmjNum,1};
        tracked_nmj = tracked_nmjs{nmjNum,1};
        Rfixed = imref2d(size(tracked_nmj(:,:,maxFrameNum)));
        affine = zeros(size(tracked_nmj),'uint16');
	
	[t1s,t2s,s1s,s2s,sh1s,sh2s] = smooth_affine(tfAffine,nFrames)

        for tNum = 1:nFrames 
            thisTform = affine2d([s1s(tNum) sh1s(tNum) 0;sh2s(tNum) s2s(tNum) 0;t1s(tNum) t2s(tNum) 1]);
            tformDets(tNum,1) = det(thisTform.T);
            tfAffineSmoothed{tNum,1} = thisTform;
            frame2register = tracked_nmj(:,:,tNum);
            [movingRegisteredAffine,~] = imwarp(frame2register,thisTform,'OutputView',Rfixed);
            affine(:,:,tNum) = movingRegisteredAffine;
        end
           
        checkEveryXFrames = 40; % needs to be multiple of nFrames
        checkAffineRegistration = zeros(size(affine,1),size(affine,2),nFrames/checkEveryXFrames,'uint16');
        cntr = 1;

	for checkFrameNum = 1:checkEveryXFrames:nFrames      
        	checkAffineRegistration(:,:,cntr) = imadjust(affine(:,:,checkFrameNum));
        	cntr = cntr+1;
        end
        clear cntr
         disp(['Finished Affine NMJ #: ',num2str(nmjNum)]);   

        FileNameApp = trackedFileNames(nmjNum).name;
        save(FileNameApp,'tfAffine','tfAffineSmoothed','affine','checkAffineRegistration','-append')
        clear affine tfAffine tfAffineSmoothed checkAffineRegistration
    end       


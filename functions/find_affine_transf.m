% Created by: Bernal Jimenez
% 03/17/2016

function [affineTransforms] = find_affine_transf(roiFile,tracked_nmjs)

    vars = load(roiFile)
    nNmjs = vars.nNmjs;
    nFrames = vars.nFrames;
    maxFrameNum = vars.maxFrameNum;

    affineTransforms = cell(nNmjs,1);

    for nmjNum = 1:nNmjs
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

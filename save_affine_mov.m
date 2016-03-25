% Created by: Bernal Jimenez
% 03/17/2016


function [] = save_affineMov_mov(affineTransforms,trackedMov,trackedFileNames,maxFrameNum,nFrames,nNmjs)

    for nmjNum = 1:nNmjs
        tfAffine = affineMovTransforms{nmjNum,1};
        trackedNmjMov = trackedMov{nmjNum,1};
        Rfixed = imref2d(size(trackedNmjMov(:,:,maxFrameNum)));
        affineMov = zeros(size(trackedNmjMov),'uint16');
	
	[t1s,t2s,s1s,s2s,sh1s,sh2s] = smooth_affineMov(tfAffine,nFrames)

        for tNum = 1:nFrames 
            thisTform = affineMov2d([s1s(tNum) sh1s(tNum) 0;sh2s(tNum) s2s(tNum) 0;t1s(tNum) t2s(tNum) 1]);
            tformDets(tNum,1) = det(thisTform.T);
            tfAffineSmoothed{tNum,1} = thisTform;
            frame2register = trackedNmjMov(:,:,tNum);
            [movingRegisteredAffine,~] = imwarp(frame2register,thisTform,'OutputView',Rfixed);
            affineMov(:,:,tNum) = movingRegisteredAffine;
        end

	nmjMovie = affineMov
           
        checkEveryXFrames = 40; % needs to be multiple of nFrames
        checkAffineRegistration = zeros(size(affineMov,1),size(affine,2),nFrames/checkEveryXFrames,'uint16');
        cntr = 1;

	for checkFrameNum = 1:checkEveryXFrames:nFrames      
        	checkAffineRegistration(:,:,cntr) = imadjust(affineMov(:,:,checkFrameNum));
        	cntr = cntr+1;
        end
        clear cntr
        disp(['Finished Affine NMJ #: ',num2str(nmjNum)]);   

        FileNameApp = trackedFileNames(nmjNum).name;
        save(FileNameApp,'tfAffine','tfAffineSmoothed','affineMov','nmjMovie','checkAffineRegistration','-append')
        clear affineMov tfAffine tfAffineSmoothed checkAffineRegistration
    end       
    
end

function [t1s,t2s,s1s,s2s,sh1s,sh2s] = smooth_affineMov(tfAffine,nFrames)

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

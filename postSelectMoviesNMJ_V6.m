clear all; close all;

% Part 1: Choose czi and movie directory
[mov_to_reg_dir,output_dir] = choose_dirs()
[roiFiles,cziFiles,nMovies] = load_mov_to_reg()

nFrames = 2000;

for movieNum=1:nMovies;
% try

    tic
    cd(mov_to_reg_dir)
    load(roiFiles(movieNum).name)

    FileName = cziFiles(movieNum).name;    
    % read movies (you need BF toolbox to read carl zeiss movies)

    [optimizer, ~] = imregconfig('multimodal');
    metric = registration.metric.MattesMutualInformation;
    optimizer.MaximumIterations = 100;
    optimizer.InitialRadius = (6.250000e-03)/6;
    optimizer.Epsilon= 1.5e-6;
    optimizer.GrowthFactor = 1.05;  

    trackingCoordinates=cell(nNmjs,1);

    %First Step Through NMJs  
    parfor nmjNum = 1:nNmjs
        
         disp(['Loading reader for NMJ #: ',num2str(nmjNum)]);   
        reader = bfGetReader(FileName);
         disp(['Finished loading reader for NMJ #: ',num2str(nmjNum)]);   

        regProps = regPropsStore{nmjNum};
        xInds = regProps.PixelList(:,1);    
        yInds = regProps.PixelList(:,2); 
        bbox = [min(regProps.PixelList(:,1)) min(regProps.PixelList(:,2)) max(regProps.PixelList(:,1))-min(regProps.PixelList(:,1)) max(regProps.PixelList(:,2))-min(regProps.PixelList(:,2))]; 
        bboxStore = bbox; 
        firstFrame = (maxFrame(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3)));
        firstFrame2ref = enhanceContrastForAffine(firstFrame);

        trackingCoords=zeros(nFrames,4);
        trackingCoords(maxFrameNum,:) = bbox;

        tformTranslation=cell(nFrames,1); 
        trackMov=zeros(size(firstFrame2ref,1),size(firstFrame2ref,2),nFrames,'uint16');
           
        minOverlap=numel(firstFrame2ref)/1.2;

            for qq =maxFrameNum+1:nFrames

                        thisFrame = bfGetPlane(reader, qq);
                        thisFramePadded = padarray(thisFrame,[100 100],mean(thisFrame(:)));
 
                    thisFrame = thisFramePadded(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3));
                    thisFrame=imadjust(thisFrame);
                    thisFrame=enhanceContrastForAffine(thisFrame);

                    c = normxcorr2_general((thisFrame),(firstFrame2ref),minOverlap);
                    [~, imax] = max(abs(c(:)));
                    [ypeak, xpeak] = ind2sub(size(c),imax(1));
                    corr_offset = [(xpeak-size(firstFrame2ref,2)) (ypeak-size(firstFrame2ref,1))];

            %                 c = normxcorr2(thisFrame(:,:,1),lastFrame(:,:,1));


                    bbox(2)=bbox(2)- corr_offset(2);
                    bbox(1)=bbox(1)- corr_offset(1);

                    trackingCoords(qq,:) = bbox;
            %         
            %         thisFrame = bfGetPlane(reader, qq);
            %         thisFramePadded = padarray(thisFrame,[100 100],mean(thisFrame(:)));
            %         nextFrameShifted = (thisFramePadded(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3)));
            % % %         
            %         imshowpair(nextFrameShifted,firstFrame2ref),drawnow;refresh
            % % % %         
            %         trackMov(:,:,qq)=(nextFrameShifted);
                     disp(['Tracking NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   
            end
                    bbox=bboxStore;

            for qq =maxFrameNum-1:-1:1
                           thisFrame = bfGetPlane(reader, qq);
                        thisFramePadded = padarray(thisFrame,[100 100],mean(thisFrame(:)));

                    thisFrame = thisFramePadded(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3));
                    thisFrame=imadjust(thisFrame);
                    thisFrame=enhanceContrastForAffine(thisFrame);

                    c = normxcorr2_general((thisFrame),(firstFrame2ref),minOverlap);
                    [~, imax] = max(abs(c(:)));
                    [ypeak, xpeak] = ind2sub(size(c),imax(1));
                    corr_offset = [(xpeak-size(firstFrame2ref,2)) (ypeak-size(firstFrame2ref,1))];

                    bbox(2)=bbox(2)- corr_offset(2);
                    bbox(1)=bbox(1)- corr_offset(1);

                    trackingCoords(qq,:) = bbox;
            % %         
            %         thisFrame = bfGetPlane(reader, qq);
            %         thisFramePadded = padarray(thisFrame,[100 100],mean(thisFrame(:)));
            %         nextFrameShifted = (thisFramePadded(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3)));
            % % %         
            %         imshowpair(nextFrameShifted,firstFrame2ref),drawnow;refresh
            % % % %         
            %         trackMov(:,:,qq)=(nextFrameShifted);
            %
                     disp(['Tracking NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   

            end
        
        
    trackingCoordinates{nmjNum,1} = trackingCoords;   
        
        
    end
    
   
    reader = bfGetReader(FileName);
        
    cd(output_dir)

    FileNameApp = FileName;
    FileNameApp(end-3:end)=[];
    mkdir(FileNameApp);cd(FileNameApp)
    
    copyfile([mov_to_reg_dir '/' roiFiles(movieNum).name],cd)

    for nmjNum = 1:nNmjs
        %track = zeros(size(
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
     toc   

end

tic
 % Affine registration
for movieNum=1:nMovies;
 % load tracked movies
    cd(output_dir)
    FileName = cziFiles(movieNum).name;
    FileNameApp = FileName;
    FileNameApp(end-3:end)=[];
    cd(FileNameApp)
    
    load(roiFiles(movieNum).name)

    trackedFileNames = dir('*register*.mat');
    trackStore = cell(nNmjs,1);
    for trackmovieNum = 1:nNmjs   
        load(trackedFileNames(trackmovieNum).name,'track','trackingCoords')
        trackStore{trackmovieNum,1}=track;
        clear track
    end
    
    affineTransforms = cell(nNmjs,1);
    
    parfor nmjNum = 1:nNmjs
        disp(['Starting affine NMJ #: ',num2str(nmjNum)])
        trackMov = trackStore{nmjNum,1};

        refFrameNorm = trackMov(:,:,maxFrameNum);
        frameIn1 = imadjust(refFrameNorm);
        background = imopen(frameIn1,strel('disk',25));
        frameIn = frameIn1 - background;
        frameIn = imadjust(frameIn);
        frameIn = wiener2(frameIn,[15 15]);
        gthresh = graythresh(frameIn);
%         refFrame = im2double(im2bw(frameIn,gthresh));
        refFrame = enhanceContrastForAffine(refFrameNorm);
	time_enhance_contrast = timeit(enhanceContrastForAffine)
%         refFrameThresh = graythresh(refFrame);
%         refFrameBW = im2bw(refFrame,refFrameThresh);
%         se = strel('disk',25);
%         refFrameBWdil = imdilate(refFrameBW,se);

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

        for qq =maxFrameNum+1:nFrames    
        
            movingFrame = enhanceContrastForAffine(trackMov(:,:,qq));
            movingFrame = imhistmatch(movingFrame,refFrame);
            movingFrame = wiener2(movingFrame,[10 10]);

%             movingFrame = enhanceContrastForAffine(trackMov(:,:,qq));

%             movingFrame = imhistmatch(movingFrame,refFrame);
%             movingFrame(~refFrameBWdil)=0;
            
            prevTformAff=tfAffine{qq-1}.T;       
            
%             sf1(qq,1)=  prevTformAff(1,1);
%             sf2(qq,1)=  prevTformAff(2,2);
%             tf1(qq,1)=  prevTformAff(3,1);
%             tf2(qq,1)=  prevTformAff(3,2);

            if prevTformAff(1,1)<scaleThresh || prevTformAff(2,2)<scaleThresh 
            prevTformAff(1,1)=1;
            prevTformAff(2,2)=1;    
            end
            
            if prevTformAff(3,1)>distTreshX || prevTformAff(3,2)>distTreshY 
            prevTformAff(3,1)=0;
            prevTformAff(3,2)=0;    
            end
            
            prevTformAff=affine2d(prevTformAff);
            tfAffine{qq,1} = imregtform(movingFrame,refFrame,'affine',optimizer,metric,...
	    time_affine_regis = timeit(imregtform)
                'InitialTransformation',prevTformAff); 
          
         
            
            
% %             
%             Rfixed = imref2d(size(refFrame));
%             [movingRegisteredAffine,~] = imwarp(movingFrame,tfAffine{qq,1},'OutputView',Rfixed); 
% %             
%             [movingRegisteredAffine2,~] = imwarp(trackMov(:,:,qq),tfAffine{qq,1},'OutputView',Rfixed);
%             tempMov(:,:,qq)=imadjust(movingRegisteredAffine2);
% %             imshowpair(imadjust(movingRegisteredAffine2),(movingFrame));drawnow;refresh
%             imshowpair(refFrame,(movingRegisteredAffine2));drawnow;refresh
% 
% %             imshow(movingFrame);drawnow;refresh
             disp(['Affine NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   

        end

        for qq =maxFrameNum-1:-1:1
                
      movingFrame = enhanceContrastForAffine(trackMov(:,:,qq));
            movingFrame = imhistmatch(movingFrame,refFrame);
            movingFrame = wiener2(movingFrame,[10 10]);

%             movingFrame = enhanceContrastForAffine(trackMov(:,:,qq));

%             movingFrame = imhistmatch(movingFrame,refFrame);
%             movingFrame(~refFrameBWdil)=0;
            
            prevTformAff=tfAffine{qq+1}.T;       
            
%             sf1(qq,1)=  prevTformAff(1,1);
%             sf2(qq,1)=  prevTformAff(2,2);
%             tf1(qq,1)=  prevTformAff(3,1);
%             tf2(qq,1)=  prevTformAff(3,2);

            if prevTformAff(1,1)<scaleThresh || prevTformAff(2,2)<scaleThresh 
            prevTformAff(1,1)=1;
            prevTformAff(2,2)=1;    
            end
            
            if prevTformAff(3,1)>distTreshX || prevTformAff(3,2)>distTreshY 
            prevTformAff(3,1)=0;
            prevTformAff(3,2)=0;    
            end
            
            prevTformAff=affine2d(prevTformAff);
            tfAffine{qq,1} = imregtform(movingFrame,refFrame,'affine',optimizer,metric,...
	    'InitialTransformation',prevTformAff);
	    time_affine_back = timeit(imregtform)
% %             
%             Rfixed = imref2d(size(refFrame));
%             [movingRegisteredAffine,~] = imwarp(movingFrame,tfAffine{qq,1},'OutputView',Rfixed); 
% %             
%             [movingRegisteredAffine2,~] = imwarp(trackMov(:,:,qq),tfAffine{qq,1},'OutputView',Rfixed);
%             tempMov(:,:,qq)=imadjust(movingRegisteredAffine2);
% %             imshowpair(imadjust(movingRegisteredAffine2),(movingFrame));drawnow;refresh
%             imshowpair(refFrame,(movingRegisteredAffine2));drawnow;refresh
% 
% %             imshow(movingFrame);drawnow;refresh

        disp(['Affine NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   


        end

    affineTransforms{nmjNum,1}= tfAffine;
    end % parfor loop end
    

    for nmjNum = 1:nNmjs
        tfAffine = affineTransforms{nmjNum,1};
        trackMov = trackStore{nmjNum,1};
        Rfixed = imref2d(size(trackMov(:,:,maxFrameNum)));
        affine = zeros(size(trackMov),'uint16');

        % make it nice and smooth
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

        for tNum = 1:nFrames 
            thisTform = affine2d([s1s(tNum) sh1s(tNum) 0;sh2s(tNum) s2s(tNum) 0;t1s(tNum) t2s(tNum) 1]);
            tformDets(tNum,1) = det(thisTform.T);
            tfAffineSmoothed{tNum,1} = thisTform;
            frame2register = trackMov(:,:,tNum);
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
end
toc

% Demon registration
for movieNum=1:nMovies;
    cd(output_dir)
    FileName = cziFiles(movieNum).name;
    FileNameApp = FileName;
    FileNameApp(end-3:end)=[];
    cd(FileNameApp)
    
    load(roiFiles(movieNum).name)

affinedFileNames = dir('*register*.mat');
affineStore = cell(nNmjs,1);
for affineMovieNum = 1:nNmjs   
    load(affinedFileNames(affineMovieNum).name,'affine','maxFrameNum')
    affineStore{affineMovieNum,1}=affine;
    clear affine
end    

demonMovies = cell(nNmjs,1);
dispFields = cell(nNmjs,1);

parfor nmjNum = 1:nNmjs   
    affineMov = affineStore{nmjNum};
        disp(['Starting Demon NMJ #: ',num2str(nmjNum)])

        refFrameNorm = affineMov(:,:,maxFrameNum);
        refFrame = enhanceContrastForDemon(refFrameNorm);

        demonDispFields = cell(nFrames,1);
        demon=zeros(size(refFrame,1),size(refFrame,2),nFrames,'uint16');

        for qq = 1:nFrames
            frameNorm = affineMov(:,:,qq);
            movingFrame=enhanceContrastForDemon(frameNorm);
            [dField,~] = imregdemons(movingFrame,refFrame,[400 200 100],...
	    'PyramidLevels',3,'AccumulatedFieldSmoothing',1);
	    time_demons = timeit(imregdemons)

            movingRegistered = imwarp(frameNorm,dField);  
%             imshow(movingFrame,[]);drawnow;refresh;
            demonDispFields{qq,1}=dField;
            demon(:,:,qq)=(movingRegistered);
            disp(['NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   
  
        end
        
        demonMovies{nmjNum,1}=demon;
        dispFields{nmjNum,1}=demonDispFields;     
end
 
 
for demonMovieNum = 1:nNmjs   
    demon=demonMovies{demonMovieNum,1};
    demonDispFields=dispFields{demonMovieNum,1};
    FileNameApp = affinedFileNames(demonMovieNum).name;
    save(FileNameApp,'demonDispFields','demon','-append')
    clear demon demonDispFields
end        
    
    


toc
% catch
% end


% cd(mov_to_reg_dir)
end


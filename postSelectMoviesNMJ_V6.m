clear all; close all;

% Part 1: Choose czi and movie directory
[mov_to_reg_dir,output_dir] = choose_dirs()
[roiFiles,cziFiles,nMovies] = load_mov_to_reg()

nFrames = 2000;

for movieNum=1:nMovies;

    tic

    cd(mov_to_reg_dir)

    % Load Variables
    load(roiFiles(movieNum).name)
    FileName = cziFiles(movieNum).name;    

    % Load the reader using bftools       
    disp(['Loading reader for NMJ #: ',num2str(nmjNum)]);   
    reader = bfGetReader(file_name);
    disp(['Finished loading reader for NMJ #: ',num2str(nmjNum)]);   

    % Calculates Tracking Coordinates for all NMJs 
    trackingCoordinates = find_tracking_coor(reader,regPropsStore,maxFrame,maxFrameNum,nFrames,NMJs)
    
    % Make Output Folder
    cd(output_dir)
    FileNameApp = FileName;
    FileNameApp(end-3:end)=[];
    mkdir(FileNameApp);
    cd(FileNameApp);
    copyfile([mov_to_reg_dir '/' roiFiles(movieNum).name],cd)
        
    % Save Smoothed Coordinates in Seperate Folders
    save_smooth_coors(reader,trackingCoordinates,nFrames,maxFrameNum,FileNameApp)

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
        refFrame = enhanceContrastForAffine(refFrameNorm);
	time_enhance_contrast = timeit(enhanceContrastForAffine)

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
            tfAffine{qq,1} = imregtform(movingFrame,refFrame,'affine',optimizer,metric,...
	    time_affine_regis = timeit(imregtform)
                'InitialTransformation',prevTformAff); 
          
             disp(['Affine NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   

        end

        for qq =maxFrameNum-1:-1:1
                
      movingFrame = enhanceContrastForAffine(trackMov(:,:,qq));
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
            tfAffine{qq,1} = imregtform(movingFrame,refFrame,'affine',optimizer,metric,...
	    'InitialTransformation',prevTformAff);
	    time_affine_back = timeit(imregtform)

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


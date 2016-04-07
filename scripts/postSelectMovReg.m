clear all; close all;

%%% Choose directories
[moviesToRegisterDir,outputDir] = choose_dirs()
[roiFiles,cziFiles,nMovies] = load_mov_names(moviesToRegisterDir)

nFrames = 1000;

for movieNum=1:nMovies;
%try    
% Loads variables
cd(moviesToRegisterDir)
load(roiFiles(movieNum).name)
cziFileName = cziFiles(movieNum).name;    

% Makes output folder
FileName = cziFileName
FileName(end-3:end)=[]
movOutputDir = [outputDir '/' FileName]
mkdir(movOutputDir)
copyfile([moviesToRegisterDir '/' roiFiles(movieNum).name],movOutputDir)
save('Timing Log')

%%% Tracks and Crops NMJs from Movies
if exist('skipTrack')
    disp('Skipping NMJ Tracking')
else
    % Loads the reader using bftools       
    reader = bfGetReader(cziFileName);
    
    tic
    % Calculates tracking coordinates for all nmjs 
    trackingCoordinates = find_tracking_coor(reader,regPropsStore,maxFrame,maxFrameNum,nFrames,nNmjs)
    trackingTime = toc
    
    tic
    % Saves smoothed movies for all nmjs in seperate folders
    save_smooth_coors(reader,trackingCoordinates,nFrames,maxFrameNum,FileName,nNmjs)
    savingTrackTime = toc
    save('Timing Log','trackingTime','savingTrackTime','-append')
end
    
%%% Applies Affine Transformations on NMJs for all Movies
if exist('skipAffine')
    disp('Skipping Affine Registration')
    skipAffine = true
else
    skipAffine = false
    % Gets movie filenames
    cd(outputDir)
    cd(FileName)
    trackedFileNames = dir('*register*.mat')
    
    % Loads variables
    load(roiFiles(movieNum).name);
    % Loads all tracked nmjs for this movie into array
    trackedMovie = load_nmjs(nNmjs,trackedFileNames);
    
    tic
    % Finds affine transform for all nmjs in this movie
    affineTransforms = find_affine_transf(roiFiles,movieNum,trackedMovie);
    affineTime = toc

    tic
    % Applies affine transformation and saves movies for all nmjs in this movie 
    save_affine_mov(affineTransforms,trackedMovie,trackedFileNames,maxFrameNum,nFrames,nNmjs);
    savingAffineTime = toc
    save('Timing Log','affineTime','savingAffineTime','-append')
end

%%% Applies Demon Transformations on NMJs for all Movies
if exist('skipDemon')
    disp('Skipping Demon Registation')
    demonTime = 0
    savingDemonTime = 0
    skipDemon = true;
else
    % Gets movie filename
    cd(outputDir)
    cd(FileName)
    trackedFileNames = dir('*register*.mat')

    % Loads variables
    load(roiFiles(movieNum).name);
    
    % Loads affined nmj movies into array
    nmjMovie = load_nmjs(nNmjs,trackedFileNames);

    tic
    % Finds and applies demon transformation onto affined nmjs in this movie
    [disp_fields_gpu, demonized_mov_gpu] = apply_demon_transf(roiFiles,movieNum,nmjMovie);
    demonTime = toc
    
    demonized_mov = gather(demonized_mov_gpu);
    disp_fields = gather(disp_fields_gpu);
    tic
    % Saves demonized nmj movies for this movie
    save_demon_mov(demonized_mov,disp_fields,trackedFileNames,nNmjs,skipAffine);
    savingDemonTime = toc
    
    save('Timing Log','demonTime','savingDemonTime','-append')

end
%catch
%end
end

cd(moviesToRegisterDir)
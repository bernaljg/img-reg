%%% Choose directories
[moviesToRegisterDir,outputDir] = choose_dirs();
[fileNames,roiFullFiles,cziFullFiles,nMovies] = load_mov_names(moviesToRegisterDir);

if exist('skipAffine')
skipAffine = skipAffine
else
skipAffine = false
end

for movieNum=1:1%nMovies;
%try    
% Loads variables
fileName = fileNames{movieNum};
roiFile = roiFullFiles{movieNum};
cziFile = cziFullFiles{movieNum};
load(roiFile);
%usernFrames = 100;
%nFrames = usernFrames;

%Makes output folder
movOutputDir = fullfile(outputDir,fileName);
mkdir(movOutputDir);
copyfile(roiFile,movOutputDir);

%%% Tracks and Crops NMJs from Movies
if exist('skipTrack')
    disp('Skipping NMJ Tracking')
else
    % Loads the reader using bftools       
    reader = bfGetReader(cziFile);
    
    tic
    % Calculates tracking coordinates for all nmjs 
    trackingCoordinates = find_tracking_coor(reader,regPropsStore,maxFrame,maxFrameNum,nFrames,nNmjs);
    trackingTime = toc
    
    tic
    % Saves smoothed movies for all nmjs in seperate folders
    save_smooth_coors(reader,trackingCoordinates,nFrames,maxFrameNum,movOutputDir,fileName,nNmjs);
    savingTrackTime = toc
    save([movOutputDir '/Tracking Timing Log'],'trackingTime','savingTrackTime')
end
    
% Gets movie filenames    
trackedFileNames = dir([movOutputDir '/track/*register*.mat']) %Makes structure object

%%% Applies Affine Transformations on NMJs for all Movies
if skipAffine
    disp('Skipping Affine Registration')
else
    % Loads variables
    load(roiFile);
    
    % Loads all tracked nmjs for this movie into array
    trackedMovie = load_nmjs(nNmjs,movOutputDir,trackedFileNames);
    
    tic
    % Finds affine transform for all nmjs in this movie
    affineTransforms = find_affine_transf(roiFile,trackedMovie);
    affineTime = toc

    tic
    % Applies affine transformation and saves movies for all nmjs in this movie 
    save_affine_mov(affineTransforms,trackedMovie,movOutputDir, trackedFileNames,maxFrameNum,nFrames,nNmjs);
    savingAffineTime = toc
    save([movOutputDir '/Affine Timing Log'],'affineTime','savingAffineTime')
end

%%% Applies Demon Transformations on NMJs for all Movies
if exist('skipDemon')
    disp('Skipping Demon Registation')
    skipDemon = true;
else
    % Loads variables
    load(roiFile);
    
    % Loads affined nmj movies into array 
    nmjMovie = load_nmjs(nNmjs,movOutputDir, trackedFileNames,skipAffine);
    
    batchDir = save_batches(nmjMovie,movOutputDir,numOfNodes,nNmjs)
    
    make_run_demons_bash(batchDir,roiFile,numOfNodes)
    
end
end
end

disp('Success')

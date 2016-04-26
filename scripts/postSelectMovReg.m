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

%Change the Number of Frames for testing
nFrames=1000
save(roiFile,'nFrames','-append')

cziFile = cziFullFiles{movieNum};
load(roiFile);

%Makes output folder
movOutputDir = fullfile(outputDir,fileName);
mkdir(movOutputDir);
copyfile(roiFile,movOutputDir);

%%% Tracks and Crops NMJs from Movies
if skipTrack
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

    %Flag to load movies from tracked or affine folder
    loadFromTracked = false

    % Loads affined nmj movies into array 
    nmjMovie = load_nmjs(nNmjs,movOutputDir, trackedFileNames,loadFromTracked);
    
    % Loads affined nmj movies into array 
    tic
    % Finds and applies demon transformation onto affined nmjs in this movie
    [disp_fields, demonized_mov] = apply_demon_transf(roiFile,nmjMovie);

    demonTime = toc
    
    tic
    % Saves demonized nmj movies for this movie
    save_demon_mov(demonized_mov,disp_fields,movOutputDir, trackedFileNames,nNmjs,skipAffine);
    savingDemonTime = toc
    save([movOutputDir '/Demon Timing Log'],'demonTime','savingDemonTime') 

end
end

disp('Success')

clear all; close all;

%%% Choose directories
[moviesToRegisterDir,outputDir] = choose_dirs()
[roiFiles,cziFiles,nMovies] = load_mov_names(moviesToRegisterDir)

nFrames = 2000;


%%% Tracks and Crops NMJs from Movies

for movieNum=1:nMovies;


    % Loads variables
    cd(moviesToRegisterDir)
    load(roiFiles(movieNum).name)
    FileName = cziFiles(movieNum).name;    

    % Loads the reader using bftools       
    reader = bfGetReader(FileName);
    
    tic
    % Calculates tracking coordinates for all nmjs 
    trackingCoordinates = find_tracking_coor(reader,regPropsStore,maxFrame,maxFrameNum,nFrames,nNmjs)
    trackingTime = toc

    % Makes output folder
    cd(outputDir)
    FileNameApp = FileName;
    FileNameApp(end-3:end)=[];
    mkdir(FileNameApp);
    cd(FileNameApp);
    copyfile([moviesToRegisterDir '/' roiFiles(movieNum).name],cd)
    
    tic
    % Saves smoothed movies for all nmjs in seperate folders
    save_smooth_coors(reader,trackingCoordinates,nFrames,maxFrameNum,FileNameApp,nNmjs)
    savingTrackTime = toc
end


%%% Applies Affine Transformations on NMJs for all Movies
 
for movieNum=1:nMovies;

    % Gets movie filenames
    cd(outputDir)
    FileName = cziFiles(movieNum).name;
    FileNameApp = FileName;
    FileNameApp(end-3:end)=[];
    cd(FileNameApp)
    trackedFileNames = dir('*register*.mat');
    
    % Loads variables
    load(roiFiles(movieNum).name);

    % Loads all tracked nmjs for this movie into array
    trackedMovie = load_tracked_nmjs(nNmjs,trackedFileNames);
    
    tic
    % Finds affine transform for all nmjs in this movie
    affineTransforms = find_affine_transf(roiFiles,movieNum,trackedMovie);
    affineTime = toc

    tic
    % Applies affine transformation and saves movies for all nmjs in this movie 
    save_affine_mov(affineTransforms,trackedMovie,trackedFileNames,maxFrameNum,nFrames,nNmjs);
    savingAffineTime = toc

end


%%% Applies Demon Transformations on NMJs for all Movies

for movieNum=1:nMovies;

    % Get movie filenames
    cd(outputDir)
    FileName = cziFiles(movieNum).name;
    FileNameApp = FileName;
    FileNameApp(end-3:end)=[];
    cd(FileNameApp)
    affinedFileNames = dir('*register*.mat');
    
    % Loads variables
    load(roiFiles(movieNum).name);

    % Loads affined nmj movies into array
    affinedMovie = load_affined_nmjs(nNmjs,affinedFileNames);

    tic
    % Finds and applies demon transformation onto affined nmjs in this movie
    [demonized_mov, disp_fields,gpuConversionTime] = apply_demon_transf(roiFiles,movieNum,affinedMovie);
    demonTime = toc
    
    tic
    % Saves demonized nmj movies for this movie
    save_demon_mov(demonized_mov,disp_fields,affinedFileNames,nNmjs);
    savingDemonTime = toc

cd(moviesToRegisterDir)

save('trial_num1','gpuConversionTime','savingDemonTime','demonTime','savingAffineTime','affineTime','trackingTime','savingTrackTime')
end

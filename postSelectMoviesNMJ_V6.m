clear all; close all;

%%% Choose directories
[mov_to_reg_dir,output_dir] = choose_dirs()
[roiFiles,cziFiles,nMovies] = load_mov_names(mov_to_reg_dir)

nFrames = 2000;


%%% Tracks and Crops NMJs from Movies

for movieNum=1:nMovies;


    % Loads variables
    cd(mov_to_reg_dir)
    load(roiFiles(movieNum).name)
    FileName = cziFiles(movieNum).name;    

    % Loads the reader using bftools       
    reader = bfGetReader(FileName);
    
    tic
    % Calculates tracking coordinates for all nmjs 
    trackingCoordinates = find_tracking_coor(reader,regPropsStore,maxFrame,maxFrameNum,nFrames,nNmjs)
    timetotrack = toc

    % Makes output folder
    cd(output_dir)
    FileNameApp = FileName;
    FileNameApp(end-3:end)=[];
    mkdir(FileNameApp);
    cd(FileNameApp);
    copyfile([mov_to_reg_dir '/' roiFiles(movieNum).name],cd)
    
    tic
    % Saves smoothed movies for all nmjs in seperate folders
    save_smooth_coors(reader,trackingCoordinates,nFrames,maxFrameNum,FileNameApp,nNmjs)
    timetosavetrack = toc
end


%%% Applies Affine Transformations on NMJs for all Movies
 
for movieNum=1:nMovies;

    % Gets movie filenames
    cd(output_dir)
    FileName = cziFiles(movieNum).name;
    FileNameApp = FileName;
    FileNameApp(end-3:end)=[];
    cd(FileNameApp)
    trackedFileNames = dir('*register*.mat');
    
    % Loads variables
    load(roiFiles(movieNum).name);

    % Loads all tracked nmjs for this movie into array
    tracked_nmjs = load_tracked_nmjs(nNmjs,trackedFileNames);
    
    tic
    % Finds affine transform for all nmjs in this movie
    affineTransforms = find_affine_transf(roiFiles,movieNum,tracked_nmjs);
    timeaffine = toc

    tic
    % Applies affine transformation and saves movies for all nmjs in this movie 
    save_affine_mov(affineTransforms,tracked_nmjs,trackedFileNames,maxFrameNum,nFrames,nNmjs);
    timesaveaffine = toc

end


%%% Applies Demon Transformations on NMJs for all Movies

for movieNum=1:nMovies;

    % Get movie filenames
    cd(output_dir)
    FileName = cziFiles(movieNum).name;
    FileNameApp = FileName;
    FileNameApp(end-3:end)=[];
    cd(FileNameApp)
    affinedFileNames = dir('*register*.mat');
    
    % Loads variables
    load(roiFiles(movieNum).name);

    % Loads affined nmj movies into array
    affined_nmjs = load_affined_nmjs(nNmjs,affinedFileNames);

    tic
    % Finds and applies demon transformation onto affined nmjs in this movie
    [demonized_mov_gpu, disp_fields_gpu,timetogpu] = apply_demon_transf(roiFiles,movieNum,affined_nmjs);
    timedemon = toc
    
    demonized_mov = gather(demonized_mov_gpu)
    disp_fields = gather(disp_fields_gpu)
    tic
    % Saves demonized nmj movies for this movie
    save_demon_mov(demonized_mov,disp_fields,affinedFileNames,nNmjs);
    timesavedemon = toc

cd(mov_to_reg_dir)

save('trial_num1','timetogpu','timesavedemon','timedemon','timesaveaffine','timeaffine','timetotrack','timetosavetrack')
end

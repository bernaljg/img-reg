clear all; close all;

%%% Choose directories
[mov_to_reg_dir,output_dir] = choose_dirs()
[roiFiles,cziFiles,nMovies] = load_mov_to_reg()

nFrames = 2000;


%%% Tracks and Crops NMJs from Movies

for movieNum=1:nMovies;

    tic

    % Loads variables
    cd(mov_to_reg_dir)
    load(roiFiles(movieNum).name)
    FileName = cziFiles(movieNum).name;    

    % Loads the reader using bftools       
    disp(['Loading reader for NMJ #: ',num2str(nmjNum)]);   
    reader = bfGetReader(file_name);
    disp(['Finished loading reader for NMJ #: ',num2str(nmjNum)]);   

    % Calculates tracking coordinates for all nmjs 
    trackingCoordinates = find_tracking_coor(reader,regPropsStore,maxFrame,maxFrameNum,nFrames,NMJs)
    
    % Makes output folder
    cd(output_dir)
    FileNameApp = FileName;
    FileNameApp(end-3:end)=[];
    mkdir(FileNameApp);
    cd(FileNameApp);
    copyfile([mov_to_reg_dir '/' roiFiles(movieNum).name],cd)
        
    % Saves smoothed movies for all nmjs in seperate folders
    save_smooth_coors(reader,trackingCoordinates,nFrames,maxFrameNum,FileNameApp)

    toc   

end

tic


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
    load(roiFiles(movieNum).name;

    % Loads all tracked nmjs for this movie into array
    tracked_nmjs = load_tracked_nmjs(nNmjs,trackedFileNames)
    
    % Finds affine transform for all nmjs in this movie
    affineTransforms = find_affine_transf(roiFiles,movieNum,tracked_nmjs)

    % Applies affine transformation and saves movies for all nmjs in this movie 
    save_affine_mov(affineTransforms,tracked_nmjs,trackedFileNames,maxFrameNum,nFrames,nNmjs)
end
toc

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
    load(roiFiles(movieNum).name)

    % Loads affined nmj movies into array
    affined_nmjs = load_affined_nmjs(nNmjs,affinedFileNames)

    % Finds and applies demon transformation onto affined nmjs in this movie
    [demonized_mov, disp_fields] = apply_demon_transf(roiFiles,movieNum,affined_nmjs)

    % Saves demonized nmj movies for this movie
    save_demon_mov(demonized_mov,disp_fields,affinedFileNames,nNmjs)
    
toc
cd(mov_to_reg_dir)

end

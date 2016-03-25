% Created by: Bernal Jimenez
% 03/17/2016


function [trackedNmjs] = load_tracked_nmjs(nNmjs,trackedFileNames)

    trackedNmjs = cell(nNmjs,1);
    for trackmovieNum = 1:nNmjs   
        load(trackedFileNames(trackmovieNum).name,'trackedMov')
        trackedNmjs{trackmovieNum,1}=trackedMov;
        clear trackedMov
    end

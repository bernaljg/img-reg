% Created by: Bernal Jimenez
% 03/17/2016


function [tracked_nmjs] = load_tracked_nmjs(nNmjs,trackedFileNames)

    tracked_nmjs = cell(nNmjs,1);
    for trackmovieNum = 1:nNmjs   
        load(trackedFileNames(trackmovieNum).name,'tracked_mov','trackingCoords')
        tracked_nmjs{trackmovieNum,1}=tracked_mov;
        clear tracked_mov
    end

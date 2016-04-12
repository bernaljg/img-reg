function [] = save_movie(movieArray,fileName)
%movieArray: Any uint8, uint16 3D array, dimension 3 is time 
%fileName: Name for movie file
    
%Process    
    maxn = double(max(max(max(movieArray))));
    movgray = mat2gray(movieArray, [0,maxn]);
    mov = permute(movgray,[1 2 4 3]);
%Save Video
    vid_writer = VideoWriter(fileName);
    open(vid_writer)
    writeVideo(vid_writer,mov)
    

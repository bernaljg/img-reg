function [] = save_movie_from_file(fileName,movieType)
%fileName: Name of a file with a registered movie saved in a .mat format
%movieType: 'demon' or 'affine'
    
%Load
    struct = load(fileName, movieType);
    mov = getfield(struct,movieType);
%Save Video
    save_movie(mov,strcat('output/',movieType));
    
    
    
    

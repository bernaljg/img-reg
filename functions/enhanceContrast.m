function frameOut = enhanceContrast(inputFrame)  

frameIn = (inputFrame);

 
        frameIn = medfilt2(frameIn,[5 5]);
        frameIn = imadjust(frameIn);
        background = imopen(frameIn,strel('disk',25));
        frameIn = frameIn - background;
        frameIn = imadjust(frameIn);
        frameIn = wiener2(frameIn,[15 15]);
        frameOut = imadjust(frameIn);


end
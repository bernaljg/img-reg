function frameOut = enhanceContrastDemon(inputFrame)  
          
    background = imopen(inputFrame,strel('disk',15));
    frameIn = inputFrame - background;
    frameIn = adapthisteq(frameIn);
    frameIn = im2uint8((frameIn));
    frameOut = imadjust(frameIn);
            
    
end
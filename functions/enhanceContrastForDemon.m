function frameOut = enhanceContrastForDemon(inputFrame)  
          
    background = imopen(inputFrame,strel('disk',15));
    frameIn = inputFrame - background;
%     frameIn = adapthisteq(frameIn);

%     frameIn = im2uint8((/zframeIn));
    frameOut = im2uint8(imadjust(frameIn));
            
    
end
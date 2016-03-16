function frameOut = enhanceContrastForAffine(varargin)  
   

            frameIn=varargin{1};
            
            
%                 frameIn=trackMov(:,:,qq);


            for ee  =1:2
                frameInA = imadjust(frameIn);
                H = fspecial('disk',5);
                frameIn = imfilter(frameInA,H,'replicate');
                background = imopen(frameIn,strel('disk',15));
                H = fspecial('disk',10);
                background = imfilter(background,H,'replicate');
                frameIn = frameInA - background;
                frameIn = imadjust(frameIn);
                frameIn = imfilter(frameIn,H,'replicate');
            end

            frameIn = imadjust(frameIn);
            frameOut=frameIn;


end
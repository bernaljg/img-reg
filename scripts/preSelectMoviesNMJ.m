% this script loads movies you want to analyze, picks the brightest frame,
% allows you select ROIs of the brightest frame, then saves the information 
% in a matrix so you can run several movies overnight
clear; close all;

% theseAreTheFilesYoureLookingFor = dir('*.czi');

moviePath = [getenv('DATA_PATH'),'/img-reg/'];
fileNames = dir([moviePath, '*.czi']);

nummovies=size(fileNames,2)

nFrames=1000; 
for movnum = 1:nummovies
    thisFile = [moviePath, fileNames(movnum).name];
    
    % read movies (you need BF toolbox to read carl zeiss movies)

    reader = bfGetReader(thisFile);
    listOfTotalVals = zeros(nFrames,1);
    MeanVal = zeros(nFrames,1);
    for ii = 1:nFrames;
        thisFrame = bfGetPlane(reader, ii);
        listOfTotalVals(ii,1)=max(thisFrame(:));
        MeanVal(ii,1)=mean(thisFrame(:));
    end
    SmoothedMaxVals=smooth(smooth(double(MeanVal),50),50);
    [LocalMax_pks,LocalMax_locs,widths,proms]=findpeaks(SmoothedMaxVals,[1:1:nFrames],'SortStr','descend');
    %figure, plot(listOfTotalVals),hold on, plot(SmoothedMaxVals,'color','r');
    %plot(LocalMax_locs,SmoothedMaxVals(LocalMax_locs),'*')
    %figure, plot(MeanVal)
    [maxValOfMov,maxFrameNum] = max(MeanVal);
    [~,minFrameNum] = min(MeanVal);
%     figure, imshow(bfGetPlane(reader,maxFrameNum),[])
    maxFrame = bfGetPlane(reader,maxFrameNum);
    for i=1:length(LocalMax_locs)
        LocalMaxStack(:,:,i)=bfGetPlane(reader,LocalMax_locs(i));
    end
    %imlook3d(LocalMaxStack)
    disp('done reading');
    
   
    
    savethisFile = thisFile;
    savethisFile(end-3:end)=[];
    savethisFile = strcat(savethisFile,'_NMJ_PreSelect');
    
 save(savethisFile,'thisFile','listOfTotalVals','maxFrame','maxFrameNum','nFrames','MeanVal','SmoothedMaxVals','LocalMax_pks','LocalMax_locs','LocalMaxStack')

close all    
end

preSelectFiles = dir([moviePath,'*PreSelect.mat']);
nummovies=size(preSelectFiles,1);

for movnum = 1:nummovies

    load([moviePath,preSelectFiles(movnum).name])
    thisFile = [moviePath, preSelectFiles(movnum).name];

    imshow(maxFrame,[])
    button = questdlg('Is this a good reference frame?');
    close all
    if strcmp(button,'Yes');
        maxFrame = maxFrame;
    else 
        h=imlook3d(LocalMaxStack);
        disp('Find frame to use as reference frame');
        uiwait(h);close all
        dlgAnswer = inputdlg('Enter the frame number you want to use');
        maxFrame = LocalMaxStack(:,:,str2double(dlgAnswer{1}));
        maxFrameNum = LocalMax_locs(str2double(dlgAnswer{1}));
    end   

    maxFrame = padarray(maxFrame,[100 100],mean(maxFrame(:)));

    imshow(maxFrame,[]);
    answer = inputdlg('How many nmjs?');
    nNmjs = str2num(answer{1});
    close all
    for nNmjNum = 1:nNmjs
        BW = roipoly(maxFrame.*((2^16)/max(maxFrame(:))));
        s = regionprops(BW,'PixelList','BoundingBox','Orientation');
        regPropsStore{nNmjNum,1} = s;
    end
    savethisFile = thisFile;
    savethisFile(end-17:end)=[];
    savethisFile = strcat(savethisFile,'_NMJ_ROIs');
    
save(savethisFile,'regPropsStore','nNmjs','thisFile','maxFrame','maxFrameNum','nFrames')
clearvars -except fileNames preSelectFiles movnum nummovies nFrames 

%         disp('Use cursor to select a crop window, right click > Create Mask when finished');
%         fig=figure;
%         imshow(imfilter(FileData(StartRange).data, fspecial('gaussian', FilterSize, FilterSigma)), [],'InitialMagnification', zoom*100);
%         hold on
%         text(10, 10, 'Define Crop Box (Connect Points, right click, create mask)','color','y','FontSize',12');
%         Crop_Region = roipoly;
%         Crop_Props = regionprops(double(Crop_Region), 'BoundingBox');
%         plot([Crop_Props.BoundingBox(1),Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[Crop_Props.BoundingBox(2),Crop_Props.BoundingBox(2)],'-','color','y','LineWidth',3);plot([Crop_Props.BoundingBox(1),Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4),Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'-','color','y','LineWidth',3);
%         plot([Crop_Props.BoundingBox(1),Crop_Props.BoundingBox(1)],[Crop_Props.BoundingBox(2),Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'-','color','y','LineWidth',3);plot([Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3),Crop_Props.BoundingBox(1)+Crop_Props.BoundingBox(3)],[Crop_Props.BoundingBox(2),Crop_Props.BoundingBox(2)+Crop_Props.BoundingBox(4)],'-','color','y','LineWidth',3); 
%         hold off
%         Crop_Region=ones(size(FileData(StartRange).data));
%         Crop_Props = regionprops(double(Crop_Region), 'BoundingBox');
close all
end
    

% 
%     
%     
% %     listOfTotalVals=series1_movie(:);
% %     maxValOfMov = max(listOfTotalVals);
%     
%     % normalize to brightest pixel of the movie
%     clear movie
%     parfor ii = 1:nFrames;
%         movie(:,:,ii) = series1_movie(:,:,ii).*((2^16)/maxValOfMov);
%     end
% %     clear series1_movie listOfTotalVals
% 
%     
%      
%     clear pixSum
%     for yy = 1:size(series1_movie,3)
%         pixSum(yy,1) = sum(sum(series1_movie(:,:,yy)));  
%     end
%     % pixSum(1:100)=0; % at the beginning there's some sort of auto adjust
%     [~,maxFrameNum]=max(pixSum);
%     [~,minFrameNum]=min(pixSum);
%     maxFrame = series1_movie(:,:,maxFrameNum);
% 
%     
%     % *****add this padding step to previous loop
%     % pad movie (this helps with initial tracking)
%     for qq = 1:nFrames
%         thisFrame = series1_movie(:,:,qq);
%        movie2(:,:,qq) = padarray(thisFrame,[100 100],mean(thisFrame(:)));
%        series1_movie(:,:,qq)=[];
%        clear thisFrame
%        
%     end
%     movStore = movie;
%     maxFrame = movie2(:,:,maxFrameNum);
% 
%     % now select ROIs, doulbe click when finished with ROIpoly to finish
%     % selecting ROI and close window
%     imshow(maxFrame.*((2^16)/maxValOfMov));
%     answer = inputdlg('How many nmjs?');
%     nNmjs = str2num(answer{1});
%     close all
%     for qq = 1:nNmjs
%         BW = roipoly(maxFrame.*((2^16)/maxValOfMov));
%         s = regionprops(BW,'PixelList','BoundingBox','Orientation');
%         regPropsStore{qq,1} = s;
%     end
% 
%     savethisFile = thisFile;
%     savethisFile(end-3:end)=[];
%     savethisFile = strcat(savethisFile,'_NMJ_ROIs');
%     
% % save(savethisFile,'regPropsStore','nNmjs','thisFile','maxFrame','maxFrameNum','nFrames')
% % clearvars -except movnum nummovies nFrames theseAreTheFilesYoureLookingFor

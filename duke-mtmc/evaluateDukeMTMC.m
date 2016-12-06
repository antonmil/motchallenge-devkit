function result = evaluateDukeMTMC(resMat, iou_threshold, world, testSet)

ROI = getROIs();

if strcmp(testSet,'easy')
    load('gt/testData.mat');
    gtMat = testData;
    testInterval = [263504:356648];
elseif strcmp(testSet,'hard')
    load('gt/testHardData.mat');
    gtMat = testHardData;
    testInterval = [227541:263503];
elseif strcmp(testSet,'trainval')
    load('gt/trainval.mat');
    gtMat = trainData;
    testInterval = [47720:227540]; % takes too long
elseif strcmp(testSet,'trainval_mini') % shorter version of trainval
    load('gt/trainval.mat');
    gtMat = trainData;
    testInterval = [127720:187540]; 
else
    
    fprintf('Unknown test set %s\n',testSet);
    return;
end



% Change frames to global time
startTimes = [5543, 3607, 27244, 31182, 1, 22402, 18968, 46766];
frames = resMat(:,3);
for cam = 1:8
    frames(resMat(:,1)==cam) = frames(resMat(:,1)==cam) + startTimes(cam) - 1;
end


% Filter rows by frame interval
resMat = resMat(ismember(frames, testInterval),:);

for cam = 1:8
    gtMat(gtMat(:,1) == cam & ~ismember(gtMat(:,3) + startTimes(cam) - 1, testInterval),:) = [];
end

% Filter rows by feet position within ROI
feetpos = [ resMat(:,4) + 0.5*resMat(:,6), resMat(:,5) + resMat(:,7)];
keep = false(size(resMat,1),1);
for cam = 1:8
    camFilter = resMat(:,1) == cam;
    keep(camFilter & inpolygon(feetpos(:,1),feetpos(:,2), ROI{cam}(:,1),ROI{cam}(:,2))) = true;
end

resMat = resMat(keep,:);
    

% Single-Cam
for camera = 1:8
    fprintf('Processing camera %d...\n',camera);
    resMatSingle = resMat(resMat(:,1)==camera, 2:9);
    gtMatSingle = gtMat(gtMat(:,1)==camera, 2:9);
    [IDP, IDR, IDF1] = IDmeasures(resMatSingle, gtMatSingle, iou_threshold, world);
    
    result{camera}.IDP= IDP;
    result{camera}.IDR = IDR;
    result{camera}.IDF1= IDF1;
    result{camera}.description = sprintf('Cam_%d',camera);
    result{camera}.allMets = evaluateTracking(result{camera}.description, gtMatSingle, resMatSingle);
    result{camera}.allMets.mets2d.m = [IDF1, IDP, IDR, result{camera}.allMets.mets2d.m];

    
end
fprintf('\n');


% Multi-Cam

% Convert data format to:
% ID, frame, left, top, width, height, worldX, worldY
SHIFT_CONSTANT = 100000000;

gtMatMulti  = gtMat(:,2:9);
resMatMulti = resMat(:,2:9);
gtMatMulti(:,2) = gtMat(:,3) + gtMat(:,1)*SHIFT_CONSTANT; % frame + cam*1000000 for frame uniqueness
resMatMulti(:,2) = resMat(:,3) + resMat(:,1)*SHIFT_CONSTANT; 
[IDP, IDR, IDF1] = IDmeasures(resMatMulti, gtMatMulti, iou_threshold, world);
result{10}.IDP= IDP;
result{10}.IDR = IDR;
result{10}.IDF1= IDF1;
result{10}.description = 'Multi-cam';

% AllCameraSingle (MC Upper bound) 
gtMatSingleAll = gtMat(:,2:9);
resMatSingleAll = resMat(:,2:9);

gtMatSingleAll(:,1) = gtMatSingleAll(:,1) + gtMat(:,1)*SHIFT_CONSTANT; % ID + cam*1000000 for ID uniqueness
resMatSingleAll(:,1) = resMatSingleAll(:,1) + resMat(:,1)*SHIFT_CONSTANT;

for cam = 1:8 % frame uniqueness
    gtMatSingleAll(gtMat(:,1)==cam,2) = gtMatSingleAll(gtMat(:,1)==cam,2) + (cam-1) * numel(testInterval);
    resMatSingleAll(resMat(:,1)==cam,2)  = resMatSingleAll(resMat(:,1)==cam,2) + (cam-1) * numel(testInterval);
end
% gtMatSingleAll(:,2) = gtMatSingleAll(:,2) + gtMat(:,1)*SHIFT_CONSTANT; % frame + cam*1000000 for frame uniqueness
% resMatSingleAll(:,2) = resMatSingleAll(:,2) + resMat(:,1)*SHIFT_CONSTANT;

[IDP, IDR, IDF1] = IDmeasures(resMatSingleAll, gtMatSingleAll, iou_threshold, world);
result{9}.IDP= IDP;
result{9}.IDR = IDR;
result{9}.IDF1= IDF1;
result{9}.description = 'Single-all';
result{9}.allMets = evaluateTracking(result{9}.description, gtMatSingleAll, resMatSingleAll);
result{9}.allMets.mets2d.m = [IDF1, IDP, IDR, result{9}.allMets.mets2d.m];


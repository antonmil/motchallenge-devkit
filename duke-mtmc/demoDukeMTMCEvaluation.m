% addpath(genpath('devkit'));

% trackerOutput = dlmread('res/baseline.txt');

world = false; % Image plane
iou_threshold = 0.5;
testSets = {'easy', 'hard'};  % 'trainval'
testSets = {'easy'};

% Evaluate
for i = 1:length(testSets)
    testSet = testSets{i};
    results{i} = evaluateDukeMTMC(trackerOutput, iou_threshold, world, testSet);

end

%% Display
% load('results.mat'); % Precomputed

% Print
for i = 1:length(testSets)
    
    result = results{i};
    fprintf('\n-------Results-------\n');
    fprintf('Test set: %s\n', testSets{i});
    % Single cameras all
    fprintf('%s\n',result{9}.description);
    printMetrics(result{9}.allMets.mets2d.m); 
    
    % Multi-cam
    k = 10;    
    fprintf(result{k}.description);
    fprintf('\tIDF1: %.2f', result{k}.IDF1);
    fprintf('\tIDP: %.2f', result{k}.IDP);
    fprintf('\tIDR: %.2f\n', result{k}.IDR);
    
    % All individual cameras
    fprintf('\n'); 
    for k = 1:8
       fprintf('%s\n',result{k}.description);
       printMetrics(result{k}.allMets.mets2d.m); 
    end

end
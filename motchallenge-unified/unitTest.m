%% Test evaluation against existing database

chls = [2,3,5];
chls=3;
benchmarkName = '3DMOT15';
ccnt=0;
allGood = -1*ones(3,1,12,14);
allMetsNames = {'Rcll', 'Prcn', 'FAR', 'GT','MT','PT','ML','FP','FN','IDSW','FM','MOTA','MOTP'};
% fid=fopen('tmp/testEvaluation.txt','w');
bmttroot = '../../';
addpath(genpath('../../scripts'));

benchmarkGtDir = '../../../data/';

for chl = chls
    ccnt=ccnt+1;
    % allSeqs = parseSequences([1,chl], getDataDir);
    
    
    testSequences = sprintf('c%d-test.txt',chl);
    qrystr=sprintf('mysql -N -se "SELECT short_name FROM bmtt.results_anton WHERE chl=''%d''"',chl); 
    [st,trackers]=system(qrystr);
    trackers=strsplit(trackers);
    
    fprintf('Challenge: %d\n',chl);
    % fprintf(fid,'Challenge: %d\n',chl);
    % trackers={'DP_NMS_16'};
    % trackers={'LMP_p', 'FLOW444','KDNT','MCMOT_HDM','NLLMPa'};
    trcnt=0;
    for tr=trackers
       try
       trcnt=trcnt+1;
       if trcnt<0, continue; end
        trackerName=char(tr);
        fprintf('Testing the following tracker number %d: %s\n',trcnt,trackerName);
        % fprintf(fid,'Tracker %10s\n',tracker);
        % resultPath = trackerResultsPath{k};
        [resultPath,shakey]=findResDir(trackerName, bmttroot)
        
        allMets = evaluateTracking(testSequences, resultPath, benchmarkGtDir,benchmarkName);
        save(sprintf('evalResults/%s/%s.mat', benchmarkName,trackerName),'allMets','trackerName','-v7.3');
       
        % Overall scores
        metsBenchmark = evaluateBenchmark(allMets, false);
        fprintf('\n');
        fprintf(' ********************* Your %s Results *********************\n', benchmarkName);
        printMetrics(metsBenchmark);
      catch err
        fprintf('Tracker eval failed: %s\n', trackerName);
	getReport(err)
        fidf=fopen(sprintf('Failed-%s.txt',trackerName), 'w');
        fprintf(fidf, '%d: %s', trcnt, trackerName);
        fclose(fidf);
      end
    end
end
% fclose(fid);

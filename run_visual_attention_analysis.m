clear; clc; close all;
%% 

addpath(genpath('edf-converter-master'));
addpath(genpath('Itti-Saliency-Based-Visual-Attention-main')); 
%% 

config = struct();
config.outputDir = fullfile('outputs');

config.heatmap.binSize = 10;      
config.heatmap.gaussianSigma = 5; 
config.heatmap.alpha = 0.5;        
config.heatmap.colormap = 'turbo'; 

config.scanpathSubjectIndex = 1; 


analysisTasks = {
  % Condition, StimulusID, StartMsg,EndMsg,NumSubjects
  'Bottom-Up', 1, 'StartStimulus 1', 'EndStimulus 1', 12;
  'Bottom-Up', 3, 'StartStimulus 3', 'EndStimulus 3', 12;
  'Bottom-Up', 4, 'StartStimulus 4', 'EndStimulus 4', 12;
  'Top-Down',  1, 'StartStimulus 1', 'StartResponse 1', 9;
  'Top-Down',  2, 'StartStimulus 2', 'StartResponse 2', 9;
  'Top-Down',  5, 'StartStimulus 5', 'StartResponse 5', 9;
};

if ~exist(config.outputDir, 'dir')
    mkdir(config.outputDir);
end

fprintf('starting mainloop.\n\n');

%% 2. MAIN PROCESSING LOOP
for i = 1:size(analysisTasks, 1)
    currentCondition = analysisTasks{i, 1};
    currentStimulusId = analysisTasks{i, 2};
    
    taskDefinition = struct();
    taskDefinition.condition = currentCondition;
    taskDefinition.stimulusId = currentStimulusId;
    taskDefinition.startMessage = analysisTasks{i, 3};
    taskDefinition.endMessage = analysisTasks{i, 4};
    taskDefinition.numSubjects = analysisTasks{i, 5};
    
    fprintf('Condition=%s, StimulusID=%d\n', ...
            taskDefinition.condition, taskDefinition.stimulusId);
    
    dataPath = fullfile(currentCondition, 'Data');
    stimuliPath = fullfile(currentCondition, 'Stimuli');
    stimulusImagePath = fullfile(stimuliPath, sprintf('%d.jpg', currentStimulusId));
    
    baseImage = imread(stimulusImagePath);
    [imgHeight, imgWidth, ~] = size(baseImage);
    fprintf(' stimulus image: %s (%d x %d pixels)\n', ...
            stimulusImagePath, imgWidth, imgHeight);
    
    allSubjectData = loadSubjectDataFromFolder(dataPath);
    
    fprintf('generating Cumulative Heatmap n');
    allFixationPoints = collectFixationsForTrial(allSubjectData, taskDefinition, [imgWidth, imgHeight]);
    outputHeatmapFile = fullfile(config.outputDir, sprintf('%s_Stimulus%d_Heatmap.png', currentCondition, currentStimulusId));
    createAndSaveHeatmap(allFixationPoints, baseImage, config.heatmap, outputHeatmapFile, taskDefinition);
    
    fprintf('\n singlesubject scanpath \n');
    scanpathSubjectData = allSubjectData{config.scanpathSubjectIndex};
    scanpathData = collectScanpathDataForTrial(scanpathSubjectData, taskDefinition, [imgWidth, imgHeight]);
    outputScanpathFile = fullfile(config.outputDir, sprintf('%s_Stimulus%d_Scanpath_Subj%d.png', ...
        currentCondition, currentStimulusId, config.scanpathSubjectIndex));
    createAndSaveScanpath(scanpathData, baseImage, outputScanpathFile, taskDefinition);
    
    
    
    fprintf(' stimulusID %d finished.\n\n', currentStimulusId);
end

fprintf('all analysis tasks completed successfully.\n');



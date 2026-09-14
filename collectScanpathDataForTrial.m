function [scanpathData] = collectScanpathDataForTrial(subjectData, taskDef, imageDims)
    % Extracts fixations and saccades for one subject for a specific trial.
    
    messages = subjectData.Events.Messages.info;
    timestamps = subjectData.Events.Messages.time;

    startTimeIdx = find(strcmp(messages, taskDef.startMessage), 1, 'first');
    endTimeIdx = find(strcmp(messages, taskDef.endMessage), 1, 'first');
    
    scanpathData = struct('fixations', [], 'saccades_start', [], 'saccades_end', []);

    if isempty(startTimeIdx) || isempty(endTimeIdx)
        fprintf('  - WARNING: Scanpath trial messages not found. Returning empty data.\n');
        return;
    end

    startTime = timestamps(startTimeIdx);
    endTime = timestamps(endTimeIdx);

    % =================================================================
    % START OF CHANGE
    % =================================================================
    % Scaling factors are now consistent for all images.
    monitorWidth = 1920; 
    monitorHeight = 1080;
    imgWidth = imageDims(1); 
    imgHeight = imageDims(2);
    scaleX = imgWidth / monitorWidth;
    scaleY = imgHeight / monitorHeight;
    % The special case for stimulus 2 is removed.
    % =================================================================
    % END OF CHANGE
    % =================================================================

    % Extract fixations
    fixIdx = find(subjectData.Events.Efix.start >= startTime & subjectData.Events.Efix.end <= endTime);
    fixX = subjectData.Events.Efix.posX(fixIdx) * scaleX;
    fixY = subjectData.Events.Efix.posY(fixIdx) * scaleY;
    scanpathData.fixations = [fixX(:), fixY(:)]; % Ensure column vectors
    
    % Extract saccades
    saccIdx = find(subjectData.Events.Esacc.start >= startTime & subjectData.Events.Esacc.end <= endTime);
    saccStartX = subjectData.Events.Esacc.posX(saccIdx) * scaleX;
    saccStartY = subjectData.Events.Esacc.posY(saccIdx) * scaleY;
    saccEndX = subjectData.Events.Esacc.posXend(saccIdx) * scaleX;
    saccEndY = subjectData.Events.Esacc.posYend(saccIdx) * scaleY;
    scanpathData.saccades_start = [saccStartX(:), saccStartY(:)]; % Ensure column vectors
    scanpathData.saccades_end = [saccEndX(:), saccEndY(:)]; % Ensure column vectors

    fprintf('[CHECKPOINT] Scanpath data collected: %d fixations, %d saccades.\n', ...
            size(scanpathData.fixations, 1), size(scanpathData.saccades_start, 1));
    assert(isstruct(scanpathData), 'Output must be a struct.');
end
function [aggregatedFixations] = collectFixationsForTrial(allSubjectData, taskDef, imageDims)

    aggregatedFixations = [];
    
    monitorWidth = 1920;
    monitorHeight = 1080;
    imgWidth = imageDims(1);
    imgHeight = imageDims(2);
    
    scaleX = imgWidth / monitorWidth;
    scaleY = imgHeight / monitorHeight;

    for i = 1:numel(allSubjectData)
        edf = allSubjectData{i};
        
        if ~isfield(edf.Events, 'Messages') || ~isfield(edf.Events, 'Efix')
            fprintf('  subject %d is missing Messages or Efix data.\n', i);
            continue;
        end
        
        messages = edf.Events.Messages.info;
        timestamps = edf.Events.Messages.time;

        startTimeIdx = find(strcmp(messages, taskDef.startMessage), 1, 'first');
        endTimeIdx = find(strcmp(messages, taskDef.endMessage), 1, 'first');
        
        if isempty(startTimeIdx) || isempty(endTimeIdx)
            fprintf('  trial messages not found for subject %d. \n', i);
            continue;
        end
        
        startTime = timestamps(startTimeIdx);
        endTime = timestamps(endTimeIdx);
        
        fixationIndices = find(edf.Events.Efix.start >= startTime & edf.Events.Efix.end <= endTime);
        
        if ~isempty(fixationIndices)
            try
          
                rawPosX = edf.Events.Efix.posX;
                rawPosY = edf.Events.Efix.posY;

                fixPosX = rawPosX(fixationIndices);
                fixPosY = rawPosY(fixationIndices);

                fixPosX_scaled = fixPosX * scaleX;
                fixPosY_scaled = fixPosY * scaleY;
                
                subjectFixations = [fixPosX_scaled(:), fixPosY_scaled(:)];
                

                aggregatedFixations = [aggregatedFixations; subjectFixations];
                fprintf('  - Collected %d fixations from subject %d.\n', numel(fixationIndices), i);

            catch ME
                fprintf('  - ERROR processing fixations for subject %d. Skipping. Error: %s\n', i, ME.message);
                continue;
            end
        else
            fprintf('  - Collected 0 fixations from subject %d for this trial.\n', i);
        end
    end
    
    fprintf('[CHECKPOINT] Total aggregated fixations for stimulus %d: %d\n', taskDef.stimulusId, size(aggregatedFixations, 1));
    if ~isempty(aggregatedFixations)
        assert(size(aggregatedFixations, 2) == 2, 'Final aggregated fixations must be an Nx2 matrix.');
    end
end
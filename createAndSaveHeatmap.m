function createAndSaveHeatmap(fixationPoints, baseImage, hmConfig, outputFilename, taskDef)
    % Generates and saves a cumulative fixation heatmap overlaid on an image.
    
    [imgHeight, imgWidth, ~] = size(baseImage);
    
    % Define histogram edges based on image dimensions
    if taskDef.stimulusId == 2
        xEdges = 0:hmConfig.binSize:1920;
        yEdges = 0:hmConfig.binSize:1080;
    else
        xEdges = 0:hmConfig.binSize:imgWidth;
        yEdges = 0:hmConfig.binSize:imgHeight;
    end
    
    if isempty(fixationPoints)
        fprintf('  - WARNING: No fixation points provided. Skipping heatmap generation for %s.\n', outputFilename);
        return;
    end
    
    % Create 2D histogram of fixation data
    heatmapRaw = histcounts2(fixationPoints(:, 1), fixationPoints(:, 2), xEdges, yEdges);

    % --- Checkpoint & Test ---
    fprintf('[CHECKPOINT] Raw heatmap data shape: [%d, %d]\n', size(heatmapRaw, 1), size(heatmapRaw, 2));
    assert(ismatrix(heatmapRaw), 'Raw heatmap must be a 2D matrix.');
    
    % Normalize and apply Gaussian blur
    if max(heatmapRaw(:)) > 0
        heatmapNormalized = heatmapRaw / max(heatmapRaw(:));
    else
        heatmapNormalized = heatmapRaw;
    end
    heatmapSmoothed = imgaussfilt(heatmapNormalized, hmConfig.gaussianSigma);
    
    % Create and save the figure
    fig = figure('Visible', 'off', 'Name', 'Heatmap'); % Create figure in background
    imshow(baseImage);
    hold on;
    
    % Overlay heatmap using imagesc for color and alpha
    imagesc(xEdges, yEdges, heatmapSmoothed', 'AlphaData', hmConfig.alpha);
    colormap(hmConfig.colormap);
    
    % Final touches
    title(sprintf('Cumulative Heatmap: %s, Stimulus %d (%d Subjects)', ...
                  taskDef.condition, taskDef.stimulusId, taskDef.numSubjects));
    xlabel('X Position (pixels)');
    ylabel('Y Position (pixels)');
    colorbar;
    hold off;
    
    % Save the figure
    saveas(fig, outputFilename);
    close(fig);
    
    fprintf('  - Heatmap saved to: %s\n', outputFilename);
    assert(exist(outputFilename, 'file') == 2, 'Output heatmap file was not created.');
end
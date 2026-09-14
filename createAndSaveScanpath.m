function createAndSaveScanpath(scanpathData, baseImage, outputFilename, taskDef)
    if isempty(scanpathData) || isempty(scanpathData.fixations)
        fprintf(' no scanpath data provided. %s.\n', outputFilename);
        return;
    end

    fixationColor = [1, 0.2, 0.2];  
    saccadeColor = [0.2, 0.6, 1];   
    fixationSize = 75;             
    saccadeLineWidth = 2.0;         
    pathAlpha = 0.7;               

    fig = figure('Visible', 'off', 'Name', 'Scanpath');
    imshow(baseImage);
    hold on;

    sacc_start = scanpathData.saccades_start;
    sacc_end = scanpathData.saccades_end;
    
    lines = plot([sacc_start(:, 1)'; sacc_end(:, 1)'], [sacc_start(:, 2)'; sacc_end(:, 2)'], ...
                 '-', 'LineWidth', saccadeLineWidth, 'Color', [saccadeColor, pathAlpha]);
    
    fixations = scanpathData.fixations;
    scatter(fixations(:, 1), fixations(:, 2), fixationSize, ...
            'MarkerFaceColor', fixationColor, ...
            'MarkerEdgeColor', 'w', ... 
            'LineWidth', 1.5, ...
            'MarkerFaceAlpha', pathAlpha, ...
            'MarkerEdgeAlpha', pathAlpha);

    title(sprintf('Scanpath: %s, Stimulus %d, Subject %d', ...
                  taskDef.condition, taskDef.stimulusId, 1)); 
    xlabel('X Position (pixels)');
    ylabel('Y Position (pixels)');
    

    h_fix = plot(NaN, NaN, 'o', 'MarkerSize', 10, 'MarkerFaceColor', fixationColor, 'MarkerEdgeColor', 'w');
    h_sac = plot(NaN, NaN, '-', 'LineWidth', saccadeLineWidth, 'Color', saccadeColor);
    legend([h_fix, h_sac], {'Fixations', 'Saccades'}, 'Location', 'northeast', 'TextColor', 'white', 'Box', 'off');

    hold off;

    saveas(fig, outputFilename);
    close(fig);
    
    assert(exist(outputFilename, 'file') == 2, 'Output scanpath file was not created.');
end
% =========================================================================
% SCRIPT STANDALONE PER L'ESECUZIONE DI ITTI_MODEL_DEMO (Versione Corretta)
%
% Descrizione:
%   Questa versione corregge il modo in cui lo script 'itti_model_demo'
%   viene eseguito, definendo una variabile prima di chiamarlo.
% =========================================================================

%% ========================================================================
%  SEZIONE 1: CARICAMENTO E CONFIGURAZIONE
% =========================================================================
clear; clc; close all;

fprintf('--- Inizializzazione dello script Demo Itti ---\n');

addpath(genpath('edf-converter-master'));
addpath(genpath('Itti-Saliency-Based-Visual-Attention-main'));
fprintf('Toolbox aggiunte al path.\n');

config = struct();
config.projectRoot = pwd;
config.outputDir = fullfile(config.projectRoot, 'outputs');

if ~exist(config.outputDir, 'dir')
    mkdir(config.outputDir);
    fprintf('Directory di output creata in: %s\n', config.outputDir);
end

fprintf('Configurazione completata. Avvio del loop principale.\n');


%% ========================================================================
%  SEZIONE 2: LOOP DEDICATO PER L'ESECUZIONE DI ITTI_MODEL_DEMO
% =========================================================================

fprintf('\n====================================================\n');
fprintf('--- Avvio della generazione della Demo del Modello Itti ---\n');

bottomUpStimuliIds = [1, 3, 4]; 
stimuliPath_BottomUp = fullfile(pwd, 'Bottom-Up', 'Stimuli');

for i = 1:length(bottomUpStimuliIds)
    
    currentStimulusId = bottomUpStimuliIds(i);
    fprintf('\n--- Esecuzione della Demo per l''ID Stimolo: %d ---\n', currentStimulusId);
    
    stimulusImagePath = fullfile(stimuliPath_BottomUp, sprintf('%d.jpg', currentStimulusId));
    
    if ~exist(stimulusImagePath, 'file')
        fprintf('  - ATTENZIONE: Immagine stimolo non trovata. Salto.\n');
        continue;
    end
    
    try
        % =================================================================
        % START OF THE FIX
        % =================================================================
        
        % Step 1: Define the variable that the script 'itti_model_demo.m' expects.
        % We assume the variable is named 'image'. If it's different (e.g., 'imgPath'),
        % change it here.
        clear image; % Clear the variable from the previous loop iteration.
        image = stimulusImagePath; % Set the variable to our current image path.
        
        % Step 2: Call the script WITHOUT any input arguments.
        % The script will use the 'image' variable we just defined.
        itti_model_demo;
        
        % =================================================================
        % END OF THE FIX
        % =================================================================
        
        % The rest of the code for saving the figure remains the same.
        figHandle = gcf; 
        outputFilename = fullfile(config.outputDir, sprintf('IttiDemo_Stimulus%d.png', currentStimulusId));
        
        title(sprintf('Demo del Modello Itti per lo Stimolo %d', currentStimulusId));
        saveas(figHandle, outputFilename);
        fprintf('  - Figura demo salvata in: %s\n', outputFilename);
        
        close(figHandle); 
        
    catch ME
        fprintf('  - ERRORE durante l''esecuzione di itti_model_demo. Salto. Errore: %s\n', ME.message);
    end
    
end

fprintf('\n--- Generazione della Demo del Modello Itti Terminata ---\n');
fprintf('====================================================\n');
function itti_model_demo(imagePath)
% =========================================================================
% MODIFIED VERSION - This is now a FUNCTION that accepts an image path.
%
% Description:
%   Takes an image path as input, runs the ittiSaliency model, and
%   displays the results in a figure window.
%
% Original Author: Osvaldo Pulpito
% Modified by: [Your Name/Project]
% =========================================================================

% --- Check if the input image exists ---
if ~exist(imagePath, 'file')
    error('Input image file does not exist: %s', imagePath);
end

% --- Run the full saliency model ---
% We request the second output ('saliencyMap') and discard the first.
[~, saliencyMap, conspI, conspC, conspOr] = ittiSaliency(imagePath);

% --- Display the results in a subplot ---
% This creates a clean visualization in the current figure window.

% Original Image
subplot(2,3,1);
imshow(imread(imagePath));
title('Original Image');

% Intensity Conspicuity
subplot(2,3,2);
imshow(conspI,[]);
title('Intensity');

% Color Conspicuity
subplot(2,3,3);
imshow(conspC,[]);
title('Color');

% Orientation Conspicuity
subplot(2,3,4);
imshow(conspOr,[]);
title('Orientation');

% Final Saliency Map
subplot(2,3,5);
imshow(saliencyMap,[]);
title('Saliency Map');

end
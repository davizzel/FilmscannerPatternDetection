%% Source folders


libRawFolder = '/Applications/LibRaw-0.20.2/bin/';

ImageFolder = '/Documents/MATLAB/Filmscanner/Test_images/FilmScanner_Optik2/';

%% Create fileList
fileList = dir( [ImageFolder, filesep, '*.CR3'] ); 
 
%check files
fileList.name
 
%% Convert RAW-files to tiffs
for ii=1:1:size(fileList,1)
    dos( [ '"', libRawFolder, 'unprocessed_raw" -T "', ...
        ImageFolder, fileList(ii).name, '"'] );
end
 
%% Show overview 
fileList = dir( fullfile( ImageFolder, '*.tiff' ) );
%  
close all


%% Detect pattern
test_image = imread('/Documents/MATLAB/Filmscanner/Test_images/FilmScanner_Optik2/IMG_0243.CR3.tiff');

size(test_image)
imshow(test_image*10)
cfa ='BGGR';
test_result = findpattern(test_image, cfa);
test_result

function coordinates = findpattern(fileID, cfa)
%% Debayer the raw tiff-file
full_image = hqlin_debayer(fileID, cfa);
%convert to grayscale for normxcorr2
full_image = im2gray(full_image);
%alt: use green channel only
%full_image = full_image(:,:,2);

size(full_image)
imshow(full_image*10)
title('Select biggest vertical pattern: click upper left corner und lower right corner');
%% Extract original pattern through slicing 
[x,y] = ginput(2);
original_pattern = full_image(y(1):y(2),x(1):x(2));
imshow(original_pattern*10)
%% Initalize arrays for matches and sizes
found_matches = [];
sizes = [];

%% Find original pattern_h first without scaling
pattern_h = original_pattern;
[ph pv] = size(pattern_h);
sizes = cat(1, sizes,[ph pv]);
correlations = normxcorr2(pattern_h, full_image);

%find maximum of correlation   
[r c v] = find(correlations == (max(max(correlations))));
found_matches = cat(1, found_matches,[r c v]); 

%% Scale pattern and match
for i = 1:1:40
    
    pattern_h = imresize(pattern_h, 0.5^(1/6));
    [ph pv] = size(pattern_h);
    sizes = cat(1, sizes,[ph pv]);
    correlations = normxcorr2(pattern_h, full_image);
    
    %find maximum of correlation
    
    [r c v] = find(correlations == (max(max(correlations))));
    found_matches = cat(1, found_matches,[r c v]);
end

%% Rotate pattern to pattern_v
pattern_v = imrotate(original_pattern, 90);

%% Find original pattern_v first without scaling
[ph pv] = size(pattern_v);
sizes = cat(1, sizes,[ph pv]);
correlations = normxcorr2(pattern_v, full_image);

%find maximum of correlation   
[u v c] = find(correlations == (max(max(correlations))));
found_matches = cat(1, found_matches,[u v c]);

%% Scale pattern and match
for i = 1:1:40
    
    pattern_v = imresize(pattern_v, 0.5^(1/6));
    [ph pv] = size(pattern_v);
    sizes = cat(1, sizes,[ph pv]);
    correlations = normxcorr2(pattern_v, full_image);
    
    %find maximum of correlation
    
    [r c v] = find(correlations == (max(max(correlations))));
    found_matches = cat(1, found_matches,[r c v]); 
end


%% draw box around matches
matched_patterns = full_image;

for n = 1:1:size(found_matches,1)
  
matched_patterns = insertShape(matched_patterns, 'rectangle', [found_matches(n, 2)-sizes(n, 1) found_matches(n, 1)-sizes(n, 2) sizes(n, 1) sizes(n, 2)], 'LineWidth', 3); %extract c and r of current_correlation

end

%% display matches
imshow(matched_patterns*10)
axis image;

%saving coordinates: upper left corner x and y,
%x-width and y-width of area
coordinates = [found_matches(n, 2)-sizes(n, 1), found_matches(n, 1)-sizes(n, 2), sizes(n, 1), sizes(n, 2)];
end

function rgb = hqlin_debayer(raw_img, cfa)
% High quality linear demosaicing
% Cutting the outer two pixel lines where no sufficient debayering is possible   

% Crop Image to correct CFA-pattern GRBG for
% debayering 
if cfa == 'GRBG'
    
    elseif cfa =='BGGR'
        raw_img = raw_img(1:end-2, 2:end-1);
        elseif cfa =='RGGB'
            raw_img = raw_img(2:end-1, 1:end-2);
            elseif cfa == 'GBRG'
                raw_img = raw_img(2:end-1, 2:end);
end

            
    rgb(:,:,1) = raw_img(:,:);
    rgb(:,:,2) = raw_img(:,:);
    rgb(:,:,3) = raw_img(:,:);
 
 
    % calculate green for non-green pixels
    rgb(3:2:(end-2),4:2:(end-2),2) = ( raw_img(2:2:(end-3),4:2:(end-2)) + raw_img(3:2:(end-2),3:2:(end-3)) + raw_img(4:2:(end-1),4:2:(end-2)) + raw_img(3:2:(end-2),5:2:(end-1)) )/4 + ( 4*raw_img(3:2:(end-2),4:2:(end-2)) - raw_img(1:2:(end-4),4:2:(end-2)) - raw_img(3:2:(end-3),2:2:(end-4)) - raw_img(3:2:(end-2),6:2:(end)) - raw_img(5:2:(end),4:2:(end-2)) )/8;
    rgb(4:2:(end-2),3:2:(end-2),2) = (raw_img(4:2:(end-2),2:2:(end-4)) + raw_img(5:2:(end),3:2:(end-2)) + raw_img(4:2:(end-2),4:2:(end-1)) + raw_img(3:2:(end-3),3:2:(end-2)))/4 + ( 4*raw_img(4:2:(end-2),3:2:(end-2)) - raw_img(4:2:(end-2),1:2:(end-4)) - raw_img(6:2:(end),3:2:(end-2)) - raw_img(4:2:(end-2),5:2:(end)) - raw_img(2:2:(end-4),3:2:(end-2)) )/8;
 
 
    % calculate red for non-red pixels
    rgb(4:2:(end-2),3:2:(end-2),1) = ( raw_img(3:2:(end-3),2:2:(end-3)) + raw_img(5:2:(end-1),2:2:(end-3)) + raw_img(5:2:(end-1),4:2:(end-1)) + raw_img(3:2:(end-3),4:2:(end-1)) )/4 + ( 4*raw_img(4:2:(end-2),3:2:(end-2)) - raw_img(2:2:(end-4),3:2:(end-2)) - raw_img(4:2:(end-2),1:2:(end-4)) - raw_img(6:2:(end),3:2:(end-2)) - raw_img(4:2:(end-2),5:2:(end)) )*3/16;
    rgb(3:2:(end-2),3:2:(end-2),1) = ( raw_img(3:2:(end-2),2:2:(end-3)) + raw_img(3:2:(end-2),4:2:(end-1)) )/2 + ( 5*raw_img(3:2:(end-2),3:2:(end-2)) + raw_img(1:2:(end-4),3:2:(end-2))/2 + raw_img(5:2:(end),3:2:(end-2))/2 - raw_img(2:2:(end-3),2:2:(end-3)) - raw_img(2:2:(end-3),4:2:(end-1)) - raw_img(4:2:(end-1),2:2:(end-3)) - raw_img(4:2:(end-1),4:2:(end-1)) - raw_img(3:2:(end-2),1:2:(end-4)) - raw_img(3:2:(end-2),5:2:(end)) )/8;
    rgb(4:2:(end-2),4:2:(end-2),1) = ( raw_img(3:2:(end-3),4:2:(end-2)) + raw_img(5:2:(end-1),4:2:(end-2)) )/2 + ( 5*raw_img(4:2:(end-2),4:2:(end-2)) - raw_img(3:2:(end-3),3:2:(end-3)) - raw_img(5:2:(end-1),3:2:(end-3)) + raw_img(4:2:(end-2),2:2:(end-4))/2 - raw_img(5:2:(end-1),5:2:(end-1)) + raw_img(4:2:(end-2),6:2:(end))/2 - raw_img(3:2:(end-3),5:2:(end-1)) - raw_img(2:2:(end-4),4:2:(end-2)) - raw_img(6:2:(end),4:2:(end-2)) )/8;
 
 
    % calculate blue for non-blue pixels
    rgb(3:2:(end-2),4:2:(end-2),3) = ( raw_img(2:2:(end-3),3:2:(end-3)) + raw_img(4:2:(end-1),3:2:(end-3)) + raw_img(4:2:(end-1),5:2:(end-1)) + raw_img(2:2:(end-3),5:2:(end-1)) )/4 + ( 4*raw_img(3:2:(end-2),4:2:(end-2)) - raw_img(1:2:(end-4),4:2:(end-2)) - raw_img(3:2:(end-3),2:2:(end-4)) - raw_img(3:2:(end-2),6:2:(end)) - raw_img(5:2:(end),4:2:(end-2)) )*3/16;
    rgb(3:2:(end-2),3:2:(end-2),3) = ( raw_img(2:2:(end-3),3:2:(end-2)) + raw_img(4:2:(end-1),3:2:(end-2)) )/2 + ( 5*raw_img(3:2:(end-2),3:2:(end-2)) - raw_img(1:2:(end-4),3:2:(end-2)) - raw_img(5:2:(end),3:2:(end-2)) - raw_img(2:2:(end-3),2:2:(end-3)) - raw_img(2:2:(end-3),4:2:(end-1)) - raw_img(4:2:(end-1),2:2:(end-3)) - raw_img(4:2:(end-1),4:2:(end-1)) + raw_img(3:2:(end-2),1:2:(end-4))/2 + raw_img(3:2:(end-2),5:2:(end))/2 )/8;
    rgb(4:2:(end-2),4:2:(end-2),3) = ( raw_img(4:2:(end-2),3:2:(end-3)) + raw_img(4:2:(end-2),5:2:(end-1)) )/2 + ( 5*raw_img(4:2:(end-2),4:2:(end-2)) - raw_img(3:2:(end-3),3:2:(end-3)) - raw_img(5:2:(end-1),3:2:(end-3)) - raw_img(4:2:(end-2),2:2:(end-4)) - raw_img(5:2:(end-1),5:2:(end-1)) - raw_img(4:2:(end-2),6:2:(end)) - raw_img(3:2:(end-3),5:2:(end-1)) + raw_img(2:2:(end-4),4:2:(end-2))/2 + raw_img(6:2:(end),4:2:(end-2))/2 )/8;
 
   
    rgb = rgb(3:(end-2), 3:(end-2), :);
end
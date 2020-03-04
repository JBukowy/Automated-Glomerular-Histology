function glomlocalizer_deNovo_split2( filename )
% YOU MUST RUN SPLIT1 FIRST AND RUN THIS FROM THE WORKING
% DIRECTORY THAT HAS THE OUTPUT FROM SPLIT1.
%
% This is the second split of the Automated Glomerular Localization
% algorithm. This is the step where the RCNN is run initially to get the
% glomerular candidates and subsequently aggregates and removes repeats.
%
% Input:
%   filename - the name of the histology file to be converted. This file
%   should be in tif format and have the ~0.68 um/px resolution. Please
%   include the image extension with the filename.
%
% Output:
%   One image file is written, "Detected Glomeruli.tif". This image
%   overlays the found glomeruli (using yellow bounding boxes) on top of
%   the equalized version of the histology image. You may find it useful to
%   overlay on top of the original, full color, image.
%
%   MAT file - "to be Scored.mat" - This is where all of the information is
%   stored. This file can be run with the supplied GUI to manually page
%   through and score the glomeruli found using this method. This matrix
%   file has a single cell matrix where each found glomeruli is stored as a
%   row.
%       - The first column is cropped, full color image, of the glomeruli.
%       - The second column is the cropped, color deconvolved image, of the
%       glomeruli.
%       - The third column is the automated glomerular score (THIS IS NOT
%       PUBLISHED YET - DO NOT USE/REPORT)
%       - The Fourth column is the calculated distance to surface of
%       the glomeruli (in pixels - if you know the resolution you can convert).
%       - The Fifth column is the absolute pixel location of the glomeruli
%       center in the original image.
%       - The Sixth column is the calculated kidney sufance border pixel
%       used in the distance calculation. (This can be helpful for
%       visualizing distances).

% Copyright (C) <2017>  <John D. Bukowy>
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

f = imread(filename);
G = imread(sprintf('%s Stain Separated.tif', filename(1:end-4)));
g = imread(sprintf('%s Stain EQ.tif', filename(1:end-4)));

f = f(:,:,1:3);
G = G(:,:,1:3);

thresh = 0.9;
load('PublishedLocalizationDetectors');

%% Block Processing for Glomerular Candidates
shift = 300;

fun = @(block_struct) detectNeighborhood_prime(block_struct.data,detector_rcnn,detector_cnn,block_struct.location,shift,thresh,filename);
Q = blockproc(g,[1000 1000],fun,'PadPartialBlocks',1,'BorderSize',[shift shift]);
%%

%% Aggregation of Glomerular Candidates and Removal of Repeats
list = dir(sprintf('*Block %s*',filename));

collector = [];
collector_smim = {};

for i = 1:length(list)
    load(list(i).name)
    collector = [collector;boxies];
    delete(list(i).name)
end

overlapRatio_u = triu(bboxOverlapRatio(collector,collector,'ratioType','Min'));
overlapRatio_b = triu(bboxOverlapRatio(collector,collector,'ratioType','Min')');

[locx_u,locy_u] = find(overlapRatio_u > .7);
[locx_b,locy_b] = find(overlapRatio_b > .7);

loc = unique([locx_u,locy_u;locx_b,locy_b],'rows','stable');

repeat = [];
j=1;
for i = 1:size(loc,1)
    if loc(i,1) ~= loc(i,2)
        repeat(j,1:2) = [loc(i,1), loc(i,2)];
        j=j+1;
    end
end

if isempty(repeat) == 0
collector(repeat(:,2),:) = [];
end
%%

%% Creation of ROI Image and Saving of Different Formats
detectedImg = insertObjectAnnotation(g, 'rectangle', collector, repmat({'Glomerulus'},[size(collector,1),1]));
imwrite(im2uint8(detectedImg),sprintf('%s Detected Glomeruli.tif', filename(1:end-4)));
%%

%% Glomerular Distance from Surface Estimation
glomloc = round(collector(:,1:2) + (collector(:,3:4)*.5));

[ borderloc ] = SmartBorder( f );
for i = 1:size(glomloc,1)
    for j = 1:size(borderloc,1)
        distmat(j,i) = sqrt((glomloc(i,1)-borderloc(j,1))^2+(glomloc(i,2)-borderloc(j,2))^2);
    end
end

glomdist = min(distmat)';
%%

%% Glomerular Injury Assessment Formatting
for i = 1:size(collector,1)
    smim_FC{i} = imcrop(G,[glomloc(i,:) - round(227/2), 227, 227]);
end

%load prod_net.mat
%
%for i = 1:length(smim_FC)
%for j = 1:30
%    predictedScore_holder(j) = (predict(prod_net{j},imresize(smim_FC{i},[227 227])));
%end
%predictedScore(i,1) = mean(predictedScore_holder);
%clear predictedScore_holder
%end
%%

for i = 1:size(collector,1)
    smim_orig{i} = imcrop(f,collector(i,:));
end

output = smim_orig(:);
output(:,2) = smim_FC(:);
% output(:,3) = num2cell(predictedScore);
output(:,4) = num2cell(glomdist);
output(:,5) = num2cell(glomloc,[size(glomloc,2) size(glomloc,1)]);
output(1,6) = mat2cell(borderloc,size(borderloc,1),size(borderloc,2));

save(sprintf('%s to be Scored.mat', filename),'output','-v7.3');

end

function glomlocalizer_deNovo_split1( filename, M )
% This is the first split of the Automated Glomerular Localization algorithm.
% This split will convert the full color (RGB) histo images into their
% color deconvolved selves. Additionally, it performs a histogram equilization
% step on the first channel. This first channel should correspond to the
% red/general staining associated with trichrom stains. It is an important
% QC step to confirm that you have the correct image saved for StainEQ
% after completing this step.
%
% Input:
%   filename - the name of the histology file to be converted. This file
%   should be in tif format and have the ~0.68 um/px resolution. Please
%   include the image extension with the filename.
%   M - OPTIONAL - If you find a color deconvolution basis  matrix that
%   works better for your stain, you can manually supply the matrix.
%
% Output:
%   This split writes out 2 image files to the current working directory.
%   "Stain seperated.tif" is the full color, color deconvoled image. Each channel
%   in this image is an intensity channel approximation for individual
%   stains used in the histological prep. "Stain EQ.tif" is the histogram
%   equalized version of the red staining required for the localization
%   pipeline.
%
% Depending on the original format of the image, it may have > 3 channels.
% (alpha?). This algorithm does not require anything other than the color
% channels.

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
f = f(:,:,1:3);
[~, mask ] = SmartBorder( f );

%% Stain Split and Color Normalization
if nargin == 2
    G = TriChromeSeperator(f,M);
else
    M = ColorConvSelector( f );
    G = TriChromeSeperator(f,M);
end
g = ROIhisteq(im2uint8(G(:,:,1)),mask);
%%

% Image write-out - Note: this step converts the images to uint8
% representations. This is required for the published CNN.
imwrite(im2uint8(G), sprintf('%s Stain Separated.tif',filename(1:end-4)));
imwrite(im2uint8(g), sprintf('%s Stain EQ.tif',filename(1:end-4)));

end

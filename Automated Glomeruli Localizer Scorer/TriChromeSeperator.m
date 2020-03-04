function [G] = TriChromeSeperator( f, M )
%TRICHROMEHTP This function returns the virtually stain seperated image given
% the original RGB color image and the color deconvolution basis matrix M.
% Run ColorConvSelector first to find M

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


g = f;
sampleRGB_OD = -log10((double(g)+1)./256);

Dbg = inv(M');

% Construct Findings
[height, width, channel] = size(f);

sampleRGB_ODTemp = reshape(sampleRGB_OD,[height*width,channel]);
G = Dbg * sampleRGB_ODTemp';
G = reshape(G',[height, width, channel]);

end

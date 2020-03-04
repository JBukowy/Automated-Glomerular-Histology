function [ e ] = anglecost( x, U, desired )
% This cost function is to assist the automated methods for color
% deconvolution. Specifically, it alters the orientation of the
% observations to confine them to the first quadrant in PCA (PC1 and PC2)
% space.
%
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

Q = U*rotz(x);
adjusted = mean(atand(Q(:,2)./Q(:,1)));

e = (adjusted-desired).^2;

end

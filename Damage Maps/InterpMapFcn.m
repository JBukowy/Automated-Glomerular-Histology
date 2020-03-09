function InterpMapFcn( filename )
%INTERPMAPFCN Summary of this function goes here
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
% load('detect_reg_trial.mat')
curdir  = pwd;
idcs   = strfind(curdir,'\');
updir = curdir(1:idcs(end)-1);
addpath(genpath(updir))

load(sprintf('%s to be Scored.mat',filename))
f = imread(filename);

[ borderidx] = SmartBorder( f );
mask = zeros(size(f,1),size(f,2));

Sigma_Map = cortexestimator(filename);

imwrite(mat2gray(Sigma_Map,[0 4]),sprintf('%s Sigma Map.tif',filename(1:end-4)));

cortex_map = (Sigma_Map>0) - (Sigma_Map>2);
cort_boundary = cell2mat(bwboundaries(cortex_map));

bb_mask = padarray(zeros(size(f,1)-2,size(f,2)-2),[1 1],1,'both');
bb_mask_struct = regionprops(bb_mask,'PixelList');
bb_mask_pos = bb_mask_struct.PixelList;

boundingbox_kidney = fliplr(cort_boundary);

bb_holder = [bb_mask_pos;boundingbox_kidney];
bb_score_holder = zeros(size(bb_holder,1),1);

pos = cell2mat(output(:,5));
if(size(output,2)>=7)
    score = cell2mat(output(:,end));
else
    score = cell2mat(output(:,3));
end

point_pos = [bb_holder;pos];
point_score = [bb_score_holder;mean(score,2)];

clear bb_holder bb_score_holder boundingbox_kidney borderidx boundingbox_image

[maskx,masky] = meshgrid(1:size(f,2),1:size(f,1));
InterpMap = griddata(point_pos(:,1),point_pos(:,2),double(point_score),maskx,masky,'cubic');

cmap = colormap(jet);

stretch_IM_1 = mat2gray(InterpMap,[0 4]);

imwrite(stretch_IM_1,sprintf('%s Raw Damage Map.tif',filename(1:end-4)));

stretch_IM_2 = gray2ind(stretch_IM_1);
stretch_IM_3 = ind2rgb(stretch_IM_2,cmap);

clear stretch_IM_1 stretch_IM_2

Q = imfuse(f,stretch_IM_3,'blend');

imwrite(im2uint8(Q),sprintf('%s Damage Map.tif',filename(1:end-4)));

close all;

end


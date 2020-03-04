function [ M ] = ColorConvSelector( f )
% This is an implementation for solving for color basis vectors of a 2-stain
% histology prep, adapated from the Macenko et al. method.
%
% Input: f - a 3 channel rgb image matrix.
% Output: M - a 3x3 matrix of the color basis vectors. This should be used
% with TriChromeSeperator.

% SmarterBorder takes an rgb image matrix of a histological sample. It is
% was designed to work with 1 or 2 'continous' samples present in the
% image.
[~,kidney_mask] = SmartBorder(f);

% This is a slightly sketchy step. It should go in and find all of the
% background that is included in holes in the tissue. This is based off of
% apply filters to image data. I don't expect this to be super robust. If
% something is wrong, this would be a good place to check.

% If working correctly, background mask should return a binary mask where
% 1's denote no tissue both within the sample and the background

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

background_pre1_mask = imgaussfilt(entropyfilt(rgb2gray(f),true(3)),5);
background_pre2_mask = (background_pre1_mask>graythresh(background_pre1_mask));
background_pre3_mask = ~background_pre2_mask-(~kidney_mask);
background_pre4_mask = imfill(background_pre3_mask,'holes');
background_mask = ~(~background_pre4_mask.*(kidney_mask));

% This step should apply the masks that we created to segment tissue pixels
% for color basis solving steps
keep_loc = reshape(background_mask(:,:,1),size(background_mask(:,:,1),1)*size(background_mask(:,:,1),2),1);
mask_loc = find(keep_loc==1);
keep_loc = find(keep_loc==0);
background_mask_x3 = repmat(background_mask,1,1,3);

f = uint8(~background_mask_x3).*f;
[height width channel] = size(f);
g = f;

% Feature Set - Optical Density of tissue
% This step solves for optical density of teh tissue and vectorizes the
% image, hence O(ptical)D(density)v(ectorized). It also samples a subset of
% the pixels.

sampleRGB_OD = -log10((double(g)+1)./256);

ODv = reshape(sampleRGB_OD(:,:,1),size(sampleRGB_OD(:,:,1),1)*size(sampleRGB_OD(:,:,1),2),1);
ODv(:,2) = reshape(sampleRGB_OD(:,:,2),size(sampleRGB_OD(:,:,1),1)*size(sampleRGB_OD(:,:,1),2),1);
ODv(:,3) = reshape(sampleRGB_OD(:,:,3),size(sampleRGB_OD(:,:,1),1)*size(sampleRGB_OD(:,:,1),2),1);

ODv_keep = ODv(keep_loc,:);
ODv_drops = prctile(mean(ODv_keep')',.1);
ODv_keep = ODv_keep(mean(ODv_keep')'>ODv_drops,:);

obvs = [ODv_keep];

% Implementation of adapated Macenko et al. method.
[S, U] = pca(obvs);

x0 = [0];
lb = -90;
ub = 90;
x = fmincon(@(x)anglecost(x,U,15),x0,[],[],[],[],lb,ub);
U = U*rotz(x);
% plot(Q(:,2),Q(:,1),'x',U(:,2),U(:,1),'o')

Q(:,1) = (U(:,1)-min(U(:,1)))./(max(U(:,1))-min(U(:,1)));
Q(:,2) = (U(:,2)-min(U(:,2)))./(max(U(:,2))-min(U(:,2)));
Q(:,3) = (U(:,3)-min(U(:,3)))./(max(U(:,3))-min(U(:,3)));

Q = Q*rotz(45);

DEGv(:,1) = asind(Q(:,2)./sqrt(Q(:,1).^2+Q(:,2).^2));
DEGv(:,2) = asind(Q(:,3)./sqrt(Q(:,1).^2+Q(:,3).^2));
DEGv(:,3) = asind(Q(:,3)./sqrt(Q(:,2).^2+Q(:,3).^2));

candidate = DEGv(:,1);

DEGv_low = prctile(candidate,5);
DEGv_high = prctile(candidate,95);

loc_low = find(candidate==max(candidate(find(candidate<=DEGv_low))));
loc_high = find(candidate==max(candidate(find(candidate>=DEGv_high))));


refOD(1,:) = double(ODv_keep(loc_low(1,:),:));
refOD(2,:) = double(ODv_keep(loc_high(1,:),:));
refOD(3,:) = [.5 0 0];

s1 = refOD(1,:);
s2 = refOD(2,:);
s3 = cross(s1,s2);

M = [s1/norm(s1); s2/norm(s2); s3/norm(s3)];

end

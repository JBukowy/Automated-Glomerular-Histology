function [ report, smim ] = detectNeighborhood_prime( S, detector_rcnn, detector_cnn, start_point, shift, thresh, filename )
% This method uses the associated CNNs to make glomerular candidate predictions
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

[bboxes, scores] = detect(detector_rcnn, S,'NumStrongestRegions',inf);

if ~isempty(scores) == 1 && sum(scores>thresh) > 0
select_bboxes = bboxes(scores>thresh,:);
for i = 1:size(select_bboxes,1)
smim{i} = imcrop(S,select_bboxes(i,:));
Results(i) = grp2idx(classify(detector_cnn,imresize(smim{i},[227 227])));
end

if sum(Results==2)>0
    boxies = select_bboxes(Results==2,:);
    boxies(:,1:2) = boxies(:,1:2) + (fliplr(start_point)-shift);
    save(sprintf('Block %s %d.mat',filename,cputime),'boxies','smim');
    report = length(boxies);
else
report = 0;
end
else
    report = 0;
end



end

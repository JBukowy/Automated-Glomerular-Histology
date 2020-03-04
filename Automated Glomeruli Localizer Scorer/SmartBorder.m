function [ borderidx, kidneymask ] = SmartBorder( f )
% Find Kidney Outline and Fill Masks. This method should handle single and
% double sample images, assuming samples are ~same size.

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

orig_size = size(f);
HWratio = orig_size(1)/(orig_size(2));

if size(f,3) > 1
g = imadjust(rgb2gray(imresize(f,[HWratio.*1000, 1000])));
he = g<(.9*255);
else
    g = imresize(f,[HWratio.*1000, 1000]);
    he = g>(.5*255);
    he = imfill(he,'holes');
end



props = regionprops(he,'Area','PixelIdxList');
for i = 1:length(props)
    area(i) = props(i).Area;
end

sort_area = sort(area,'descend');

if sort_area(2) < .8*sort_area(1)
objkeep = find(area==sort_area(1));
augimgsize = size(g);
kidneymask = zeros(augimgsize(1:2));
kidneymask(props(objkeep).PixelIdxList) = 1;
clear props
else
    objkeep(1) = find(area==sort_area(1));
    objkeep(2) = find(area==sort_area(2));

    augimgsize = size(g);
kidneymask = zeros(augimgsize(1:2));
kidneymask(props(objkeep(1)).PixelIdxList) = 1;
kidneymask(props(objkeep(2)).PixelIdxList) = 1;

end

clear props area


kidneymask = imfill(kidneymask,'holes');
kidneymask = activecontour(g,kidneymask,'Chan-Vese','SmoothFactor',3);

if max(max(bwlabel(kidneymask))) > size(objkeep,2)
    props = regionprops(kidneymask,'Area','PixelIdxList');
    for i = 1:length(props)
        area(i) = props(i).Area;
    end

    sort_area = sort(area,'descend');

    if sort_area(2) < .8*sort_area(1)
        objkeep = find(area==sort_area(1));
        augimgsize = size(g);
        kidneymask = zeros(augimgsize(1:2));
        kidneymask(props(objkeep).PixelIdxList) = 1;
        clear props
    else
        objkeep(1) = find(area==sort_area(1));
        objkeep(2) = find(area==sort_area(2));

        augimgsize = size(g);
        kidneymask = zeros(augimgsize(1:2));
        kidneymask(props(objkeep(1)).PixelIdxList) = 1;
        kidneymask(props(objkeep(2)).PixelIdxList) = 1;

    end
    clear props
end

props = regionprops(kidneymask,'Area','PixelIdxList');

for w = 1:length(props)

    tempmask = zeros(augimgsize);
    tempmask(props(w).PixelIdxList) = 1;


    for n = 1:1

        skelletor = bwmorph(bwmorph(tempmask.*imfill(tempmask,'holes'),'skel',inf),'endpoints');

        clear loc
        [loc(:,1), loc(:,2)] = find(skelletor==1);

        clear distmat
        for i = 1:size(loc,1)
            for j = 1:size(loc,1)
                distmat(j,i) = sqrt((loc(i,1)-loc(j,1))^2+(loc(i,2)-loc(j,2))^2);
            end
        end

        distmat(distmat==0) = NaN;
        distmat(distmat>50) = NaN;
        [x,y] = find(distmat==min(distmat));

        pairs = [];
        if isempty(x) == 0
        for m = 1:size(x,1)
            pairs(:,1:2) = [loc(x,1),loc(x,2)];
            pairs(:,3:4) = [loc(y,1),loc(y,2)];
        end
        end

        if isempty(pairs) == 0
        for a = 1:size(pairs,1)

            for i=1:1
                p(1,:)=[pairs(a,1), pairs(a,2)];
                for j=i+1:2
                    p(2,:)=[pairs(a,3), pairs(a,4)];
                    nPixels=max(abs(p(1,:)-p(2,:)))+1;
                    X=linspace(p(1,2), p(2,2), nPixels);
                    Q=(p(1,1)-p(2,1))/(p(1,2)-p(2,2));
                    if isinf(Q)
                        Y=linspace(p(1,1),p(2,1),nPixels);
                    else
                        Q(2)=-det(p)/(p(1,2) - p(2,2));
                        Y=(Q(1)*X+Q(2));
                    end
                    skelletor(sub2ind(size(skelletor),round(Y),round(X)))=1;
                end
            end

        end
        end

        kidneymask = (skelletor+kidneymask>0);
        kidneymask = imfill(kidneymask,'holes');

    end

end

kidneybordermask = bwmorph(kidneymask,'perim8');

kidneymask = imresize(kidneymask,[orig_size(1),orig_size(2)]);
kidneybordermask = imresize(kidneybordermask,[orig_size(1),orig_size(2)]);

clear props;

props = regionprops(kidneybordermask,'PixelList');

borderidx = [];
for i = 1:size(props,1)
borderidx = [borderidx;props(i).PixelList];
end


end

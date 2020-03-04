function [ new_im ] = ROIhisteq( select_layer, mask )
% Provide a masked region and the image that you would like to be histogram
% equalized. This algo will only use the pixels within the mask for
% equalization. Modified from source (1)
% (1) https://www.asee.org/documents/sections/middle-atlantic/spring-2010/Implementing-a-Histogram-Equalization-Algorithm.pdf
pixlist = regionprops(mask,'PixelIdxList');
im_array = select_layer(pixlist.PixelIdxList);

M = size(im_array,1);

histy = zeros (1,256);
for i = 1:M
    gp = im_array(i);
    Temp = histy(gp+1)+1; % Adjust gp to go from 1 to G, not 0 to G-1
    histy(gp+1) = Temp;
end

histy_cumulative = zeros (1,256);
histy_cumulative(1) = histy(1);
for p = 2:256
    A = histy_cumulative(p - 1) + histy(p);
    histy_cumulative(p) = A;
end

%Set
histy_lookup = zeros (1,256);
for p = 1:256
    A = round(((256-1)/(M)).*histy_cumulative(p));
    histy_lookup(p) = A;
end

im_array_histy = zeros (1,M);
for i = 1:M
    gp = im_array(i);
    Temp = histy_lookup(gp+1); % Adjust gp to go from 1 to G, not 0 to G-1
    im_array_histy(i) = Temp;
end

new_im = zeros(size(mask));
new_im(pixlist.PixelIdxList) = im_array_histy;
new_im = uint8(new_im);

end


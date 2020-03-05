function [ Q ] = cortexestimator( filename )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
load(sprintf('%s to be Scored.mat',filename))
f = imread(filename);
% mask = zeros(size(f,1),size(f,2));
pos = cell2mat(output(:,5));

% Near Neighbor Average Glomerular Density
neighbors = 5;
glom_distance = sort(dist(pos'),1);

avg_glom_N_dist = mean(mean(glom_distance(2:neighbors+1,:),1));
%

% Polar Coord for Cort Border
[ borderidx, kidneymask ] = SmartBorder( f );

kidneyborder = zeros(size(kidneymask));
for i = 1:length(borderidx)
    kidneyborder(borderidx(i,2),borderidx(i,1)) = 1;
end

glommask = zeros(size(kidneymask));
for i = 1:length(pos)
    glommask(pos(i,2),pos(i,1)) = 1;
end
h = strel('disk', 100);
glommask = imdilate(glommask,h);

hight = 3600*2;
with = 3600*2;

sm_img = size(imresize(kidneyborder,.1));

padder = [round(sm_img(2)/2) round(sm_img(1)/2)];

pad_mask_border = padarray(imresize(kidneyborder,.1),padder,0,'both');
pad_mask_glom = padarray(imresize(glommask,.1),padder,0,'both');

warning off
imP_border = ImToPolar(pad_mask_border, 0, 1, hight, with);
imP_glom = ImToPolar(pad_mask_glom, 0, 1, hight, with);
warning on

pix_border_P = bwmorph(imP_border>0,'shrink',inf);
pix_border_P = regionprops(pix_border_P,'PixelList');
pix_border_P = pix_border_P.PixelList;
pix_border_P_x = pix_border_P(:,1);
pix_border_P_y = hight - pix_border_P(:,2);

imP_glom_P = bwlabel(imP_glom); 
imP_glom_P = regionprops(imP_glom_P,'Centroid');
imP_glom_P = struct2cell(imP_glom_P)';
imP_glom_P = cell2mat(imP_glom_P);
imP_glom_P_x = imP_glom_P(:,1);
imP_glom_P_y = hight - imP_glom_P(:,2);

[fitresult, gof] = createFit([imP_glom_P_x (imP_glom_P_x+(max(imP_glom_P_x))) (imP_glom_P_x+(2.*(max(imP_glom_P_x))))]...
, [ imP_glom_P_y imP_glom_P_y imP_glom_P_y]);

cort_mod_center = fitresult(with+1:2*with);
glom_std = std(imP_glom_P_y);


cort_mod_center = (hight - cort_mod_center);
cort_sig1 = cort_mod_center - glom_std;
cort_sig2 = cort_mod_center - 2*glom_std;
cort_sig3 = cort_mod_center - 3*glom_std;

cort_map = zeros(hight,with);
for i = 1:with
cort_map(round(max(1,cort_mod_center(i))),i) = 1;    
cort_map(round(max(1,cort_sig1(i))),i) = 2;
cort_map(round(max(1,cort_sig2(i))),i) = 3;
cort_map(round(max(1,cort_sig3(i))),i) = 4;
end

warning off
imR = PolarToIm (cort_map, 0, 1, size(pad_mask_border,1),size(pad_mask_border,2));
warning on

newsize = [size(f,1) size(f,2)];


imR_circ = imcrop(imR,  [ round(size(imR,2)/2) - round(sm_img(2)/2)...
    round(size(imR,1)/2) - round(sm_img(1)/2)...
    round(sm_img(2))...
    round(sm_img(1))]);

filled_img = bwlabel(filledgegaps(imR_circ, 50));

filled_img_sig(:,:,1) = imresize(kidneymask,[size(filled_img,1) size(filled_img,2)]);
filled_img_sig(:,:,2) = imfill(filled_img==2,'holes');
filled_img_sig(:,:,3) = imfill(filled_img==3,'holes');
filled_img_sig(:,:,4) = imfill(filled_img==4,'holes');

filled_img_sig = sum(filled_img_sig,3);

Q = imresize(filled_img_sig,[size(f,1) size(f,2)],'method','nearest');


end



function [fitresult, gof] = createFit(x, y)
%CREATEFIT1(X,Y)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : x
%      Y Output: y
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 20-Oct-2017 17:14:28


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( x, y );

% Set up fittype and options.
ft = fittype( 'smoothingspline' );
opts = fitoptions( 'Method', 'SmoothingSpline' );
opts.SmoothingParam = 1e-08;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
% figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, xData, yData );
% legend( h, 'y vs. x', 'untitled fit 1', 'Location', 'NorthEast' );
% Label axes
% xlabel x
% ylabel y
% grid on

end


function imP = ImToPolar (imR, rMin, rMax, M, N)
% IMTOPOLAR converts rectangular image to polar form. The output image is 
% an MxN image with M points along the r axis and N points along the theta
% axis. The origin of the image is assumed to be at the center of the given
% image. The image is assumed to be grayscale.
% Bilinear interpolation is used to interpolate between points not exactly
% in the image.
%
% rMin and rMax should be between 0 and 1 and rMin < rMax. r = 0 is the
% center of the image and r = 1 is half the width or height of the image.
%
% V0.1 7 Dec 2007 (Created), Prakash Manandhar pmanandhar@umassd.edu

[Mr Nr] = size(imR); % size of rectangular image
Om = (Mr+1)/2; % co-ordinates of the center of the image
% Om = round(cntpts(1));
On = (Nr+1)/2;
% On = round(cntpts(2));

% imR = padarray(imR,round(max(OmR,OnR)).*ones(1,2),0,'both');

sx = (Mr-1)/2; % scale factors
sy = (Nr-1)/2;

imP  = zeros(M,  N);

delR = (rMax - rMin)/(M-1);
delT = 2*pi/N;

% loop in radius and 
for ri = 1:M
for ti = 1:N
    r = rMin + (ri - 1)*delR;
    t = (ti - 1)*delT;
%     ri
%     ti
    x = r*cos(t);
    y = r*sin(t);
    xR = x*sx + Om;  
    yR = y*sy + On; 
    imP (ri, ti) = interpolate1 (imR, xR, yR);
end
end

end

function v = interpolate1 (imR, xR, yR)
    xf = floor(xR);
    xc = ceil(xR);
    yf = floor(yR);
    yc = ceil(yR);
    if xf == xc & yc == yf
        v = imR (xc, yc);
    elseif xf == xc
        v = imR (xf, yf) + (yR - yf)*(imR (xf, yc) - imR (xf, yf));
    elseif yf == yc
        v = imR (xf, yf) + (xR - xf)*(imR (xc, yf) - imR (xf, yf));
    else
       A = [ xf yf xf*yf 1
             xf yc xf*yc 1
             xc yf xc*yf 1
             xc yc xc*yc 1 ];
       r = [ imR(xf, yf)
             imR(xf, yc)
             imR(xc, yf)
             imR(xc, yc) ];
       a = A\double(r);
       w = [xR yR xR*yR 1];
       v = w*a;
    end

end

function imR = PolarToIm (imP, rMin, rMax, Mr, Nr)
% POLARTOIM converts polar image to rectangular image. 
%
% V0.1 16 Dec, 2007 (Created) Prakash Manandhar, pmanandhar@umassd.edu
%
% This is the inverse of ImToPolar. imP is the polar image with M rows and
% N columns of data (double data between 0 and 1). M is the number of
% samples along the radius from rMin to rMax (which are between 0 and 1 and
% rMax > rMin). Mr and Nr are the number of pixels in the rectangular
% domain. The center of the image is assumed to be the origin for the polar
% co-ordinates, and half the width of the image corresponds to r = 1.
% Bilinear interpolation is performed for points not in the imP image and
% points not between rMin and rMax are rendered as zero. The output is a Mr
% x Nr grayscale image (with double values between 0.0 and 1.0).


imR = zeros(Mr, Nr);
Om = (Mr+1)/2; % co-ordinates of the center of the image
On = (Nr+1)/2;
sx = (Mr-1)/2; % scale factors
sy = (Nr-1)/2;

[M N] = size(imP);

delR = (rMax - rMin)/(M-1);
delT = 2*pi/N;

for xi = 1:Mr
for yi = 1:Nr
    x = (xi - Om)/sx;
    y = (yi - On)/sx;
    r = sqrt(x*x + y*y);
    if r >= rMin & r <= rMax
       t = atan2(y, x);
       if t < 0
           t = t + 2*pi;
       end
       imR (xi, yi) = interpolate2 (imP, r, t, rMin, rMax, M, N, delR, delT);
    end
end
end
end

function v = interpolate2 (imP, r, t, rMin, rMax, M, N, delR, delT)
    ri = 1 + (r - rMin)/delR;
    ti = 1 + t/delT;
    rf = floor(ri);
    rc = ceil(ri);
    tf = floor(ti);
    tc = ceil(ti);
    if tc > N
        tc = tf;
    end
    if rf == rc & tc == tf
        v = imP (rc, tc);
    elseif rf == rc
        v = imP (rf, tf) + (ti - tf)*(imP (rf, tc) - imP (rf, tf));
    elseif tf == tc
        v = imP (rf, tf) + (ri - rf)*(imP (rc, tf) - imP (rf, tf));
    else
       A = [ rf tf rf*tf 1
             rf tc rf*tc 1
             rc tf rc*tf 1
             rc tc rc*tc 1 ];
       z = [ imP(rf, tf)
             imP(rf, tc)
             imP(rc, tf)
             imP(rc, tc) ];
       a = A\double(z);
       w = [ri ti ri*ti 1];
       v = w*a;
    end
end


% FILLEDGEGAPS  Fills small gaps in a binary edge map image
%
% Usage: bw2 = filledgegaps(bw, gapsize)
%
% Arguments:    bw - Binary edge image
%          gapsize - The edge gap size that you wish to be able to fill.
%                    Use the smallest value you can. (Odd values work best). 
%
% Returns:     bw2 - The binary edge image with gaps filled.
%
%
% Strategy: A binary circular blob of radius = gapsize/2 is placed at the end of
% every edge segment.  If the ends of two edge segments are in close proximity
% the circular blobs will overlap.  The image is then thinned.  Where circular
% blobs at end points overlap the thinning process will leave behind a line of
% pixels linking the two end points.  Where an end point is isolated the
% thinning process will erode the circular blob away so that the original edge
% segment is restored.
%
% Use the smallest gapsize value you can.  With large values all sorts of
% unwelcome linking can occur.
%
% The circular blobs are generated using the function CIRCULARSTRUCT which,
% unlike MATLAB's STREL, will accept real valued radius values.  Note that I
% suggest that you use an odd value for 'gapsize'.  This results in a radius
% value of the form x.5 being passed to CIRCULARSTRUCT which results in discrete
% approximation to a circle that seems to respond to thinning in a 'good'
% way. With integer radius values CIRCULARSTRUCT can produce circles that
% result in minor artifacts being generated by the thinning process.
%
% See also: FINDENDSJUNCTIONS, FINDISOLATEDPIXELS, CIRCULARSTRUCT, EDGELINK

% Copyright (c) 2013 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% PK May 2013

function bw = filledgegaps(bw, gapsize)
    
    [rows, cols] = size(bw);
    
    % Generate a binary circle with radius gapsize/2 (but not less than 1)
    blob = circularstruct(max(gapsize/2, 1));
    
    rad = (size(blob,1)-1)/2;  % Radius of resulting blob matrix. Note
                               % circularstruct returns an odd sized matrix
    
    % Get coordinates of end points and of isolated pixels
    [~, ~, re, ce] = findendsjunctions(bw);
    [ri, ci] = findisolatedpixels(bw);
    
    re = [re;ri];
    ce = [ce;ci];

    % Place a circular blob at every endpoint and isolated pixel
    for n = 1:length(re)
        
        if (re(n) > rad) && (re(n) < rows-rad) && ...
                (ce(n) > rad) && (ce(n) < cols-rad)

            bw(re(n)-rad:re(n)+rad, ce(n)-rad:ce(n)+rad) = ...
                bw(re(n)-rad:re(n)+rad, ce(n)-rad:ce(n)+rad) | blob;
        end
    end
    
    bw = bwmorph(bw, 'thin', inf);  % Finally thin
    
    % At this point, while we may have joined endpoints that were close together
    % we typically have also generated a number of small loops where there were
    % more than one endpoint close to an edge.  To address this we identfy the
    % loops by finding 4-connected blobs in the inverted image.  Blobs that are
    % less than or equal to the size of the blobs we used to link edges are
    % filled in, the image reinverted and then rethinned.
    
    L = bwlabel(~bw,4); 
    stats = regionprops(L, 'Area');
    
    % Get blobs with areas <= pi* (gapsize/2)^2
    ar = cat(1,stats.Area);
    ind = find(ar <= pi*(gapsize/2)^2);
    
    % Fill these blobs in image bw
    for n = ind'
        bw(L==n) = 1;
    end
    
    bw = bwmorph(bw, 'thin', inf);  % thin again
    
end

% FINDENDSJUNCTIONS - find junctions and endings in a line/edge image
%
% Usage: [rj, cj, re, ce] = findendsjunctions(edgeim, disp)
% 
% Arguments:  edgeim - A binary image marking lines/edges in an image.  It is
%                      assumed that this is a thinned or skeleton image 
%             disp   - An optional flag 0/1 to indicate whether the edge
%                      image should be plotted with the junctions and endings
%                      marked.  This defaults to 0.
%
% Returns:    rj, cj - Row and column coordinates of junction points in the
%                      image. 
%             re, ce - Row and column coordinates of end points in the
%                      image.
%
% See also: EDGELINK
%
% Note I am not sure if using bwmorph's 'thin' or 'skel' is best for finding
% junctions.  Skel can result in an image where multiple adjacent junctions are
% produced (maybe this is more a problem with this junction detection code).
% Thin, on the other hand, can produce different output when you rotate an image
% by 90 degrees.  On balance I think using 'thin' is better. Skeletonisation and
% thinning is surprisingly awkward.

% Copyright (c) 2006-2013 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% November 2006  - Original version
% May      2013  - Call to bwmorph to ensure image is thinned was removed as
%                  this might cause problems if the image used to find
%                  junctions is different from the image used for, say,
%                  edgelinking 

function [rj, cj, re, ce] = findendsjunctions(b, disp)

    if nargin == 1
	disp = 0;
    end
    
    % Set up look up table to find junctions.  To do this we use the function
    % defined at the end of this file to test that the centre pixel within a 3x3
    % neighbourhood is a junction.
    lut = makelut(@junction, 3);
    junctions = applylut(b, lut);
    [rj,cj] = find(junctions);
    
    % Set up a look up table to find endings.  
    lut = makelut(@ending, 3);
    ends = applylut(b, lut);
    [re,ce] = find(ends);    

    if disp    
	show(edgeim,1), hold on
	plot(cj,rj,'r+')
	plot(ce,re,'g+')    
    end

%----------------------------------------------------------------------
% Function to test whether the centre pixel within a 3x3 neighbourhood is a
% junction. The centre pixel must be set and the number of transitions/crossings
% between 0 and 1 as one traverses the perimeter of the 3x3 region must be 6 or
% 8.
%
% Pixels in the 3x3 region are numbered as follows
%
%       1 4 7
%       2 5 8
%       3 6 9

end

function b = junction(x)
    
    a = [x(1) x(2) x(3) x(6) x(9) x(8) x(7) x(4)]';
    b = [x(2) x(3) x(6) x(9) x(8) x(7) x(4) x(1)]';    
    crossings = sum(abs(a-b));
    
    b = x(5) && crossings >= 6;
    
%----------------------------------------------------------------------
% Function to test whether the centre pixel within a 3x3 neighbourhood is an
% ending. The centre pixel must be set and the number of transitions/crossings
% between 0 and 1 as one traverses the perimeter of the 3x3 region must be 2.
%
% Pixels in the 3x3 region are numbered as follows
%
%       1 4 7
%       2 5 8
%       3 6 9

end

function b = ending(x)
    a = [x(1) x(2) x(3) x(6) x(9) x(8) x(7) x(4)]';
    b = [x(2) x(3) x(6) x(9) x(8) x(7) x(4) x(1)]';    
    crossings = sum(abs(a-b));
    
    b = x(5) && crossings == 2;
    
    
end

% FINDENDSJUNCTIONS - find isolated pixels in a binary image
%
% Usage: [r, c] = findisolatedpixels(b)
% 
% Argument:      b - A binary image 
%
% Returns:    r, c - Row and column coordinates of isolated pixels in the
%                    image. 
%
% See also: FINDENDSJUNCTIONS
%

% Copyright (c) 2013 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% May      2013 

function [r, c] = findisolatedpixels(b)

    lut = makelut(@isolated, 3);
    isolate = applylut(b, lut);
    [r, c] = find(isolate);
end
    
function b = isolated(x)
    
    b = x(5) && sum(x(:)) == 1;
end


% CIRCULARSTRUCT
%
% Function to construct a circular structuring element
% for morphological operations.
%
% function strel = circularstruct(radius)
%
% Note radius can be a floating point value though the resulting
% circle will be a discrete approximation
%
% Peter Kovesi   March 2000

function strel = circularstruct(radius)

if radius < 1
  error('radius must be >= 1');
end

dia = ceil(2*radius);  % Diameter of structuring element

if mod(dia,2) == 0     % If diameter is a odd value
 dia = dia + 1;        % add 1 to generate a `centre pixel'
end

r = fix(dia/2);
[x,y] = meshgrid(-r:r);
rad = sqrt(x.^2 + y.^2);  
strel = rad <= radius;

end

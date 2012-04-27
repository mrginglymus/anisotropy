%ALIGNMENT
%
%   Given a feature filled image from the optosplit, determines optimimum
%   alignment and prints to file
%



function [ r1, r2 ] = alignment( varargin )

% check inputs

numvarargs = length( varargin );
%{
if numvarargs == 0
    % ask user for file selection
    [ name, path ] = uigetfile( '.tif',...
        'Please select the image for alignment' );
    alignFile = strcat( path, name );
elseif
    numvarargs == 1
    % file was provided
    alignFile = varargin{ 1 };
else
    error( 'alignment takes one input argument - file location of the alignment file' );
end
%}
alignFile = ('/Volumes/WAC26/2012 04 26/calibrate.tif');
close all;

% open alignment image
aim = imread( alignFile );
stats = regionprops( im2bw( aim, graythresh( aim ) ), 'Extrema', 'BoundingBox' );

r1 = getrect( stats(1).Extrema );
r2 = getrect( stats(2).Extrema );

for i=1:20
r1 = optx( aim, r1, r2 );
r1 = opty( aim, r1, r2 );
end


end



function [ r1 ] = optx( aim, r1, r2 )
r1u = r1.shiftx(1);
r1d = r1.shiftx(-1);

[ exu, ~ ] = er( aim, r1u, r2 );
[ ex, ~ ] = er( aim, r1, r2 );
[ exd, ~ ] = er( aim, r1d, r2 );

if exu < ex || exd < ex
    if exu < exd
        r1 = r1u;
    else
        r1 = r1d;
    end
end

end

function [ r1 ] = opty( aim, r1, r2 )
r1r = r1.shifty(1);
r1l = r1.shifty(-1);

[ ~, eyr ] = er( aim, r1r, r2 );
[ ~, ey ] = er( aim, r1, r2 );
[ ~, eyl ] = er( aim, r1l, r2 );

if eyr < ey || eyl < ey
    if eyr < eyl
        r1 = r1r;
    else
        r1 = r1l;
    end
end

end


function [ ex, ey ] = er( aim, r1, r2 )
im1 = r1.cutim( aim );
im2 = r2.cutim( aim );

im1m = mean( im1(:) );
im1mv = mean( im1, 1 ) - im1m;
im1mh = mean( im1, 2 ) - im1m;

im2m = mean( im2(:) );
im2mv = mean( im2, 1 ) - im2m;
im2mh = mean( im2, 2 ) - im2m;

ex = im1mv - im2mv;
ex = sqrt(ex*ex'/length(ex));

ey = im1mh - im2mh;
ey = sqrt(ey'*ey/length(ey));

end


function [ r ] = getrect( stats )
x1 = min( stats([1,6],1 ) ) + 0.5;
x2 = max( stats([2,5],1) ) - 0.5;
y1 = min( stats([3,8],2 ) ) + 0.5;
y2 = max( stats([4,7],2) ) - 0.5;
r = MyRect( x1, x2, y1, y2 );
end

function [ r1, r2 ] = matchrect( r1, r2, factor )
minw = floor( min( [ r1.w, r2.w ] ) * factor );
minh = floor( min( [ r1.h, r2.h ] ) * factor );
r1 = r1.resize( minw, minh );
r2 = r2.resize( minw, minh );
end
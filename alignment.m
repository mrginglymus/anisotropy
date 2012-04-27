%ALIGNMENT
%
%   Given a feature filled image from the optosplit, determines optimimum
%   alignment and prints to file
%



function [ r1, r2 ] = alignment( varargin )

% check inputs

numvarargs = length( varargin );

if numvarargs == 0
    % ask user for file selection
    [ name, path ] = uigetfile( '.tif',...
        'Please select the image for alignment' );
    alignFile = strcat( path, name );
    [ name, path ] = uiputfile( '.mat',...
        'Please select output file' );
    outFile = strcat( path, name );
elseif numvarargs == 1
    % file was provided
    alignFile = varargin{ 1 };
else
    error( 'alignment takes one input argument - file location of the alignment file' );
end

% open alignment image
aim = imread( alignFile );

% pick out the two images, roughly
stats = regionprops( im2bw( aim, graythresh( aim ) ), 'Extrema', 'BoundingBox' );

% generate rectangles bordering the images
r1 = getrect( stats(1).Extrema );
r2 = getrect( stats(2).Extrema );

% match the dimensions (i.e. smallest x, smallest y) of the two rectangles
% and shrink by a factor (e.g. 0.9)
[ r1, r2 ] = matchrect( r1, r2, 0.9 );

% move the rectangle r1 up+down, left+right to get best fit
for i=1:50
r1 = opt( aim, r1, r2, 'x' );
r1 = opt( aim, r1, r2, 'y' );
end

if numvarargs == 0
    % write output for later use
    save( outFile, 'r1', 'r2' );

    % cut out the image for display
    im1 = r1.cutim( aim );
    im2 = r2.cutim( aim );

    % as an RGB image
    im(:,:,1) = im1;
    im(:,:,2) = im2;
    im(:,:,3) = zeros(size(im1));

    figure(1)
    subplot(2,2,[1,3])
    imshow(im);

    % and the alignment plots
    subplot(2,2,2);
    plot( [ flatten( aim, r1, 'x' ) ; flatten( aim, r2, 'x' ) ]' );

    subplot(2,2,4);
    plot( [ flatten( aim, r1, 'y' ) ; flatten( aim, r2, 'y' ) ]' );
end

end



function [ r1 ] = opt( aim, r1, r2, d )

r1u = r1.shift( d, +1 );
r1d = r1.shift( d, -1 );

eu = er( aim, r1u, r2, d );
es = er( aim, r1 , r2, d );
ed = er( aim, r1d, r2, d );

if eu < es || ed < es
    if eu < ed
        r1 = r1u;
    else
        r1 = r1d;
    end
end

end


function er = er( aim, r1, r2, d )

im1m = flatten( aim, r1, d );
im2m = flatten( aim, r2, d );

er = im1m - im2m;
er = sqrt( er * er' / length( er ) );

end

function imm = flatten( aim, r, d )

if strcmp( d, 'x' )
    dd = 1;
else
    dd = 2;
end

imm = double( mean( r.cutim( aim ), dd ) );

D = [ ones( 1, length( imm ) ); 1:length( imm ) ];

if dd == 2
    imm = imm';
end

imslope = imm / D;

imm = imm - ( imslope * D );

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
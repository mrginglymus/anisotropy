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
r1 = getrect( stats(1).Extrema )

stats(1).Extrema

stats(1).BoundingBox

r2 = getrect( stats(2).Extrema )

stats(2).Extrema

stats(2).BoundingBox

imshow( aim );

end




function [ r ] = getrect( stats )
r.x1 = min( stats([1,6],1 ) ) + 0.5;
r.x2 = max( stats([2,5],1) ) - 0.5;
r.y1 = min( stats([3,8],2 ) ) + 0.5;
r.y2 = max( stats([4,7],2) ) - 0.5;



end
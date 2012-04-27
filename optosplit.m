%OPTOSPLIT
%
%   Given a calibration file, splits a 3-dimensional timelapse of images
%   (X,Y,t) into a 4-dimensional timelapse of images (X,Y,t,c).

function [ imout ] = optosplit( varargin )

% check inputs

numvarargs = length( varargin );

if numvarargs == 0
    % prompt for user file selection
    % select alignment file from ImageJ
    [ name, path ] = uigetfile( {
        '*.mat','.mat alignment';...
        '*.tif','.tif alignment';...
        '*.ali','.ali alignment' },...
        'Please select the alignment file' );
    alignFile = strcat( path, name );
    % select image file
    [ name, path ] = uigetfile( '.tif',...
        'Please select the image file' );
    imFile = strcat( path, name );
    % select output file
    [ name, path ] = uiputfile( '.tif',...
        'Please select output file' );
    imout = strcat( path, name );
elseif numvarargs == 3
    % files were provided
    alignFile = varargin{ 1 };
    imFile = varargin{ 2 };
    imout = varargin{ 3 };
else
    error( 'optosplit takes three input arguments - file locations for the alignment file, the image file, and output location' );
end

% read in the java object containing the alignment box

% open alignment file
fin = java.io.FileInputStream( alignFile );
% prepare object streamer
ois = java.io.ObjectInputStream( fin );
% read off first rectangle
r1 = ois.readObject()
% and second rectangle
r2 = ois.readObject()

% close the streamers
clear( 'fin', 'ois' );

% delete the file if it currently exists
if isequal( exist( imout, 'file' ), 2 )
    delete( imout )
end

% check how many time steps there are
timeSteps = length( imfinfo( imFile ) );

if numvarargs == 0
    % only display waitbar if we're working interactively
    h = waitbar(0,'Splitting Images');
end
for t = 1:timeSteps
    % load the time frame
    im = imread( imFile, t );
    % pick out the two images
    i1 = imcrop( im, r1 );
    i2 = imcrop( im, r2 );
    % add them to the output file
    imwrite( i1, imout, 'WriteMode', 'Append' );
    imwrite( i2, imout, 'WriteMode', 'Append' );
    if numvarargs == 0
        % update progress
        waitbar( t/timeSteps, h )
    end
end
% close the wait bar
if numvarargs == 0
    close(h)
end

% fiddle with the metadata to make imageJ display it as a hyperstack
% open image for modification
tiffFile = Tiff( imout, 'r+' );
% add the necessary metadata
tiffFile.setTag( 'ImageDescription', sprintf('ImageJ=1.46k\nimages=%i\nchannels=2\nframes=%i\nhyperstack=true\nloop=false', timeSteps*2, timeSteps) )
% commit changes
tiffFile.rewriteDirectory();
% close handler
tiffFile.close();

end

function [ imout ] = imcrop( im, r )

% crops an image given a java rectangle class OR a matlab struct containing
% x, y, width and height

imout = im(r.y:r.y+r.height, r.x:r.x+r.width);

end
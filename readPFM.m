% readPFM(filename)
%
% Reads a Portable Float Map (PFM) from file located in filename
%
% Official formats:
%   A greyscale PFM (header: 'Pf') is returned as a (height x width)
%   matrix.
%
%   An RGB color PFM (header: 'PF') is returned as a (height x width x 3)
%   matrix.
%
% Unofficial formats:
function [image, scale] = readPFM(filename)

fid = fopen(filename);
% Read header.
id = fgetl(fid);
wh = fgetl(fid);
dim = sscanf(wh, '%d');
% Photoshop saves PFM files with width and height on separate lines.
if numel(dim) == 1
   height = fgetl(fid);
   height = sscanf(height, '%d');
   dim = [dim; height];
end
scale = fgetl(fid);
scale = sscanf(scale, '%f');

% TODO: deal with endianness.
% scale = abs(scale);

data = fread(fid, inf, 'float32');
fclose(fid);

if strcmp(id, 'PF')
    % float32x3
    nch = 3;
    
    % Check size.
    if size(data, 1) == nch * prod(dim),
        
        redIndices = 1 : nch : size(data, 1);
        red = data(redIndices);
        green = data(redIndices + 1);
        blue = data(redIndices + 2);
        
        % Transpose each image plane.
        image = zeros(dim(2), dim(1), nch);
        image(:, :, 1) = reshape(red, dim(1), dim(2))';
        image(:, :, 2) = reshape(green, dim(1), dim(2))';
        image(:, :, 3) = reshape(blue, dim(1), dim(2))';
    else
        error('File size and image dimensions mismatched.');
    end
elseif strcmp(id, 'Pf')
    % float32x1
    
    % Check size.
    if size(data, 1) == prod(dim)   
        image(:, :) = reshape(data, dim(1), dim(2))';
    else
        error('File size and image dimensions mismatched.');
    end
elseif strcmp(id, 'PF4')
    % Unofficial: float32x4.
    nch = 4;
    
    % Check size.
    if size(data, 1) == nch * prod(dim),
        
        redIndices = 1 : nch : size(data, 1);
        red = data(redIndices);
        green = data(redIndices + 1);
        blue = data(redIndices + 2);
        alpha = data(redIndices + 3);
        
        % Transpose each image plane.
        image = zeros(dim(2), dim(1), nch);
        image(:, :, 1) = reshape(red, dim(1), dim(2))';
        image(:, :, 2) = reshape(green, dim(1), dim(2))';
        image(:, :, 3) = reshape(blue, dim(1), dim(2))';
        image(:, :, 4) = reshape(alpha, dim(1), dim(2))';
    else
        error('File size and image dimensions mismatched.');
    end
elseif strcmp(id, 'PF2')
    % Unofficial: float32x2.
    nch = 2;
    
    % Check size.
    if size(data, 1) == nch * prod(dim),
        
        redIndices = 1 : nch : size(data, 1);
        red = data(redIndices);
        green = data(redIndices + 1);
        
        % Transpose each image plane.
        image = zeros(dim(2), dim(1), nch);
        image(:, :, 1) = reshape(red, dim(1), dim(2))';
        image(:, :, 2) = reshape(green, dim(1), dim(2))';
    else
        error('File size and image dimensions mismatched.');
    end
else
    error('Invalid file header.');
end

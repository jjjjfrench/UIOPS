function cipunp(rawcip,unpcip,lastbyte)
% CIPUNP - unpack CIP data
%
% cipunp(rawcip,unpcip)
%   rawcip   - file name of the packed data
%   unpcip   - file name to write unpacked data to
%   lastbyte - the value to use if the first byte is a 'repeat'

% Number of 4112 byte frames to process at a time
frames = 1000;
frmlen = 4112 * 4;	% Frame length in number of 2 bit values;
% Number of 2 bit values to process at a time
blksz = frames * frmlen;

% Check if the file exists
dl = dir(rawcip);
if isempty(dl)
  disp(['CIP file: ' rawcip ' does not exist.']);
  return;
end

% Open the input and output files
fin  = fopen(rawcip,'r','ieee-be');
fout = fopen(unpcip,'w','ieee-be');

% Last value processed from the previous file
if nargin > 2
  l = uint8(lastbyte);
else
  l   = uint8(0);
end

% Loop until there is no more data
while (1)

% Read in some datam 2 bits into each 8 bit number
  [b,n] = fread(fin,blksz,'ubit2=>uint8');
  if n==0; break; end
% Number of frames read in
  nf = floor(n / frmlen);
% Shorten the data if not an even number of frames
  b  = b(1:nf*frmlen);
% Eliminate the time stamps (16 bytes or 64 two bit values at the start of each
% 4112 byte frame)
  b  = reshape(b,frmlen,nf);
  b  = b(65:end,:);
  n  = numel(b);
% fprintf('Read %d bytes\n', ftell(fin));
  
% Process four 2 bit values at a time
  b  = reshape(b,4,n/4);

% The number of values from each record is variable.  Use iii to
% be '1' if the value is set, zero otherwise
  iii = zeros(127,size(b,2),'uint8');
% Holds the unpacked values
  bbb = zeros(127,size(b,2),'uint8');
% Array to hold the last value in the last record
  lbyte = zeros(1,size(b,2),'uint8');
% Set to the last value of the last processing block
  lbyte(1) = l;
  
  % Packed with three values
  i = find(b(1,:) == 1);
  iii(1:3,i) = 1;
  bbb(1:3,i) = b(2:4,i);
  lbyte(i+1) = b(4,i);
% fprintf('3 values: %d\n', length(i))
  
  % Packed with two values
%  i = find((b(1,:) == 0) & ((b(2,:) == 1) | (b(2,:) == 3)));
  i = find((b(1,:) == 0) & (b(2,:) == 1));
  iii(1:2,i) = 1;
  bbb(1:2,i) = b(3:4,i);
  lbyte(i+1) = b(4,i);
% fprintf('2 values: %d\n', length(i))
  
  % Packed with one value
%  i = find((b(1,:) == 0) & ((b(2,:) == 0) | (b(2,:) == 2)));
  i = find((b(1,:) == 0) & (b(2,:) == 0));
  iii(1,i) = 1;
  bbb(1,i) = b(3,i);
  lbyte(i+1) = b(3,i);
% fprintf('1 value:  %d\n', length(i))
  
  % The last value from the last record is repeated
  i = find(b(1,:) > 1);
% fprintf('Repeats:  %d\n', length(i))
  count = int32(64*mod(b(1,i),2) + 16*b(2,i) + 4*b(3,i) + b(4,i));

% Loop since each time through may depend on the last byte of the
% last time through and the number of values is variable
  for j = 1:length(i)
    jj = i(j);				% Record number
    iii(1:count(j),jj) = 1;		% Last value of the last record
    bbb(:,jj)          = lbyte(jj);	% Quicker to fill entire row
    lbyte(jj+1)        = lbyte(jj);	% The last value of this record
  end
  
% Write out the block with the two bit values packed into 8 bits
% 'logical(iii(:))' only writes out values where iii=1
  fwrite(fout,bbb(logical(iii(:))),'ubit2');

% Get the last value of this block to use the next time around
  l = bbb(end,logical(iii(:,end)));
  l = l(end);
end % while reading file

% Close the files
fclose(fin);
fclose(fout);

% Print some statistics
dout = dir(unpcip);
fprintf('CIP file: %s\nexpanded from %d bytes to %d, a factor of %f\n', ...
  rawcip, dl.bytes, dout.bytes, dout.bytes/dl.bytes);

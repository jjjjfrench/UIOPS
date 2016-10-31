function [idx,secofday,nslice,pcount] = cipindex(data)
% cipindex - find the start of particle for unpacked CIP images
% 
% [idx, secofday, nslice, pcount] = cipindex(data)
%
% data - two bit gray scale values in a uint8 array
%
% idx      - the index into the array of 2 bit values to the start of the 
%   image slices;
% secofday - the second of the day
%   Note, this is really only second of a twelve hour period
% nslice   - the number of slices in the particle
% pcount   - the internal particle number
%
% Note: the documentation states that there should be 56 bits of 0's and
%   then 8 bits of TAS.  The TAS is zero in our files so I look for 64 bits
%   of 0's.

% Look for at least 128 values of the number 3 followed by 32 zeros
idx   = find(data<3);
idx   = idx(find(diff(idx)>127)+1);

% The particle header extends 96 values, eliminate values near the end of data
idx   = idx(idx<length(data)-96);

% Check for 32 zeros after the 128 threes
%
% Set index to 64 values after the threes (start of image slices)
ii  = idx(:,ones(1,32)) + ones(size(idx)) * [0:31];
idx = idx(sum(data(ii),2)==0) + 64;

% Get the headers (64 2 bit words)
ii      = idx(:,ones(1,64)) + ones(size(idx)) * [0:63];
hdr     = double(data(ii-32));

% Used to decode arrays of 2 bit values
fours   = power(4,0:15)';

% Get the particle count and slices
pcount  = hdr(:,1:8) * fours(1:8);
nslice  = hdr(:,29:32) * fours(1:4);
fprintf('Found %d particles.\n', length(pcount));

% Eliminate bad values
tic
ii = ones(size(pcount));

% Eliminate particles with zero slices
n     = find(nslice==0);
ii(n) = 0;
fprintf('%d particles with zero slices removed.\n', length(n));

% Look for short particles
n = find(idx(2:end)-idx(1:end-1)-nslice(1:end-1)*64-128<0);
ii(n) = 0;
fprintf('%d short particles removed.\n', length(n));
ii     = logical(ii);
hdr    = hdr(ii,:);
idx    = idx(ii);
pcount = pcount(ii);
nslice = nslice(ii);

% Decode the time
hours   = bitshift(hdr(:,26:28) * fours(1:3),-1);

% Increment hours if they run through 00Z or 12Z
% Assume the first time stamp is correct
ii = find(hours < hours(1));
hours(ii) = hours(ii) + 12;

minutes = bitand(bitshift(hdr(:,23:26) * fours(1:4),-1),fours(4)-1);
seconds = bitand(bitshift(hdr(:,20:23) * fours(1:4),-1),fours(4)-1);
msec    = bitand(bitshift(hdr(:,15:20) * fours(1:6),-1),fours(6)-1);
usec    = bitand(bitshift(hdr(:,10:15) * fours(1:6),-1),fours(6)-1);
%nsec    = bitshift(hdr(:,9:10) * fours(1:2),-1);	% 125 ns each
nsec    = bitand(hdr(:,9:10) * fours(1:2),7);		% 125 ns each
secofday = hours*3600 + minutes*60 + seconds + ...
      msec*1E-3 + usec*1E-6 + nsec*125E-9;

% Looking for backwards time jumps with repeated particles
ii = ones(size(pcount));
d  = find(diff(secofday)<0);
n1  = 0;
n2  = 0;
verbose=false;
for jj = 1:length(d)
  k = d(jj);
  l = k+1;
  while (secofday(l) <= secofday(k)) | (pcount(l) <= pcount(k))
    ii(l) = 0;
    if ( l == length(secofday) );         break; end
    if ( pcount(k) - pcount(l) > 32768 ); break; end
    l     = l + 1;
    n1    = n1 + 1;
  end
  if verbose
    fprintf('Time jumped from %s to %s\n', ...
      datestr(secofday(k)/86400,'HH:MM:SS.FFF'), ...
      datestr(secofday(k+1)/86400,'HH:MM:SS.FFF'));
    fprintf('Remove particles %d-%d, sequence is now: %d,%d\n', ...
      pcount(k+1),pcount(l-1),pcount(k),pcount(l));
  end
  if ( pcount(k) - pcount(l) < 32768 ); n2 = n2 + pcount(l)-pcount(k)-1; end
end
fprintf( ...
  '%d particles with backwards time jumps removed, %d particles lost.\n', ...
  n1,n2);
ii       = logical(ii);
idx      = idx(ii);
pcount   = pcount(ii);
nslice   = nslice(ii);
secofday = secofday(ii);
return

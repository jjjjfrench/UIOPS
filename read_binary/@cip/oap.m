function [oapdata,timestamp] = oap(obj,filen,csvtime,csvtas)
% OAP - Read a CIP file and convert it to NCAR/OAP
%
% [oapdata,timestamp] = oap(cipfile)
%   filen   - The file number in obj.cipfile to process
%   csvtime - The Matlab times from the csv files
%   csvtas  - The true air speeds from the csv files
%
%   oapdata  - 4116xN array of OAP formated data
%     format
%      1-2  'C5'
%      3-4  hour
%      5-6  minute
%      7-8  second
%      9-10 year (not set)
%     11-12 month (not set)
%     13-14 day (not set)
%     15-16 tas (m/s not set)
%     17-18 millisec
%     19-20 overload (0)
%     21-4116  image data
% timestamp Matlab time for the end of each record

if filen < 1 || filen > obj.nfiles
  oapdata   = [];
  timestamp = [];
  return
end

% Initialize some values
twos  = power(2,31:-1:0)';
syncval = uint32(hex2dec('AAAAAA00'));
mask32  = uint64(hex2dec('FFFFFFFF'));
hdrlen = 5;
reclen = 1024 + hdrlen;	% An OAP record is 1029 32 bit values long

% The probe ID for the CIP is set to C5 because xpms2d has a particular
% format for the timing word that is constructed here
% 0xAAAAAAxxxxxxxxxx, where the time part is the number of 12 MHz
% clicks since UTC midnight.
% NCAR uses the number of 12 MHz clicks since the probe was turned on but
% I don't believe it matters.

probeid  = 'C5';
id       = double(probeid)*[256;1];

% Open the file of unpacked cip images
fprintf('Reading %s\n',obj.cipfile{filen})
fin  = fopen(obj.cipfile{filen},'r','ieee-be');
data = fread(fin,'ubit2=>uint8');
fclose(fin);

% Find the start index, time, and number of slices for each particle
disp('Calling cipindex')
[idx,parttm,ns]=cip.cipindex(data);

% Convert two bit values to one bit
data = data > 1;

% CIP image data are on a 12 hour clock
startdate = floor(csvtime(1));

% Convert the particle times to days
delt  = mod(csvtime(1),1)*86400 - parttm(1);
if delt > 7*3600 && delt < 17*3600;   parttm = parttm + 12*3600; end
if delt > -15*3600 && delt < -9*3600; parttm = parttm - 12*3600; end

% Interpolate the true airspeeds from the CSV files for each particle
tas   = interp1((csvtime-startdate)*86400,csvtas,parttm);

% Construct the timing words
dsec  = uint64(parttm' * 12E6);
tword = [bitor(syncval,uint32(bitshift(dsec,-32))); ...
         uint32(bitand(dsec,mask32))];

% Convert the particle times to Matlab time
parttm = startdate + parttm/86400;

% data is now uint8 values with one bit each.  Each OAP record
% holds 512 64 bit values.
nrec = (sum(ns) + length(ns))/512;
nrec      = floor(nrec);
oapdata   = zeros(reclen,nrec,'uint32');
timestamp = zeros(1,nrec);
irec      = 1;
jj        = hdrlen+1;
hdr       = zeros(10,1,'uint16');
[~,~,endian] = computer;
e         = endian == 'L';

% Loop through each CIP particle
for i=1:length(idx)-1
  % Pad by 64 values to insert timer word later
  img = double(data(idx(i):idx(i)+(ns(i)+1)*64-1));
  nw  = ns(i)*2 + 2;
  % Convert the 1 bit values to 32 bit values (two 32 bit values per slice)
  img = reshape(img,32,nw)' * twos;
  % Append with timer word
  img(nw-1) = tword(1,i);
  img(nw)   = tword(2,i);
  % Check to see if the full particle fits in the record
  nrem = reclen-jj+1;
  if nw > nrem
    % Write out what fits
    oapdata(jj:reclen,irec) = img(1:nrem);
    dv = datevec(parttm(i));
    % Pack 10 uint16 into 5 uint32
    % ID, hour; minute, second; year, month; day, tas; millisec, overload
    % Account for endian when doing a typecast
    % OAP files are big endian, swap the header values around
    hdr(1+e) = id;
    hdr(2-e) = dv(4);
    hdr(3+e) = dv(5);
    hdr(4-e) = floor(dv(6));
    hdr(5+e) = dv(1);
    hdr(6-e) = dv(2);
    hdr(7+e) = dv(3);
    hdr(8-e) = round(tas(i));
    hdr(9+e) = round(mod(dv(6),1) * 1000);
    % convert swapped header of 2 byte values to 4 byte
    oapdata(1:hdrlen,irec) = typecast(hdr,'uint32');
    timestamp(irec) = parttm(i);
    irec = irec + 1;
    % Save the rest of the particle
    jj = nw-nrem+hdrlen+1;
    oapdata(hdrlen+1:jj-1,irec) = img(nrem+1:end);
  else
    % It all fits, stuff it in
    oapdata(jj:jj+nw-1,irec) = img;
    jj = jj + nw;
  end
end
irec = irec - 1;
oapdata = oapdata(:,1:irec);
timestamp = timestamp(1:irec);


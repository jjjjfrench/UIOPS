function write2d(obj,filebase)
% WRITE2D - Convert an unpacked CIP file to RAF/OAP format
%
% write2d(obj,filebase)
%   obj      - CIP class object
%   filebase - the base of the file name
%     if not specified, use the first eight characters of cipfile
%     (YYYYMMMDD)

if nargin < 2
  fbase = obj.cipfile{1};
  fbase = fbase(1:8);
else
  fbase = filebase;
end

% Read the CIP csv data
[csvsod,csvtas,dt] = obj.ciptas(obj.csvfile);

% Open the output file
outfile = [fbase '_cip.2d'];
fprintf('Writing %s\n',outfile);
f2d = fopen(outfile,'w','ieee-be');

% The probe ID for the CIP is set to C5 because xpms2d has a particular
% format for the timing word that is constructed here
% 0xAAAAAAxxxxxxxxxx, where the time part is the number of 12 microsec
% clicks since UTC midnight.

probeid  = 'C5';
id       = uint16(double(probeid)*[256;1]);
dstr     = datestr(dt,'mm/dd/yyyy');
xmlstart = '<OAP version="1">';

% Read in the PMS (1D-C and 1D-P) file
pmsfile = [ fbase '_pms.2d' ];
converttas = false;
if exist(pmsfile,'file')
  fid = fopen(pmsfile,'r','ieee-be');
  fprintf('Opened %s\n', pmsfile);
  while (1)
    line = fgetl(fid);
    % Check for the old style <PMS2D> files instead of <OAP> where
    % the true air speed is scaled by 255/125
    if ~isempty(strfind(line,'<PMS2D>'))
      converttas = true;
      fprintf(f2d,'%s\n',xmlstart);
      continue;
    end
    % Don't include the <Source> attribute
    if ~isempty(strfind(line,'<Source>')); continue; end
    % Found the end of the xml header
    if ~isempty(strfind(line,'</OAP>'));   break; end
    if ~isempty(strfind(line,'</PMS2D>')); break; end
    fprintf(f2d,'%s\n',line);
  end
  % Read the PMS data
  pms   = fread(fid,'*uint16');
  npms  = length(pms)/2058;
  pms   = reshape(pms,2058,npms);
  % Calculate the record times
  hd    = double(pms(1:9,:));
  pmstm = datenum(hd(5,:),hd(6,:),hd(7,:),...
    hd(2,:),hd(3,:),hd(4,:)+hd(9,:)/1000);
  % Convert the tas if needed
  if converttas; pms(8,:) = uint16(hd(8,:) * 125 / 255); end
  clear hd;
else
% Write the header if there is no PMS 2D file to copy it from
  fprintf('The PMS 2D file: %s was not found.\n', pmsfile);
  fprintf(f2d,'<?xml version="1.0" encoding="ISO08858-1"?>\n');
  fprintf(f2d,'%s\n',xmlstart);
    fprintf(f2d, ...
    ' <Institution>University of Wyoming Atmospheric Science</Institution>\n');
  fprintf(f2d, ...
    ' <FormatURL>http://www.eol.ucar.edu/raf/Software/OAPfiles.html</FormatURL>\n');

% If there is no PMS 2d file to merge the data with, try reading the
% Project and FlightNumber from a raw file
  rawfile = [fbase '_raw.nc'];
  if exist(rawfile,'file')
    nc = netcdf.open(rawfile,0);
    fprintf('Reading attributes from %s\n',rawfile);
    proj = netcdf.getAtt(nc,netcdf.getConstant('NC_GLOBAL'),'ProjectName');
    fprintf(f2d,' <Project>%s</Project>\n',proj);
    flt  = netcdf.getAtt(nc,netcdf.getConstant('NC_GLOBAL'),'FlightNumber');
    fprintf(f2d,' <FlightNumber>%s</FlightNumber>\n',flt);
    netcdf.close(nc);
  end
  fprintf(f2d,' <FlightDate>%s</FlightDate>\n',dstr);
  fprintf(f2d,' <Platform>N2UW</Platform>\n');
  npms = 0;
end

% Write the XML <probe> attributes for the CIP
fprintf(f2d,[' <probe id="%s" type="Fast2DC" resolution="25" ' ...
  'nDiodes="64" suffix="_IBR"/>\n'],...
  probeid);
fprintf(f2d,'</OAP>\n');

% Initialize some values
rec   = zeros(1024,1,'uint32');
twos  = power(2,31:-1:0)';
tmask = uint32(hex2dec('AAAAAA00'));
ipms  = 1;

% Open and read each file of unpacked cip images
for ii = 1:length(obj.cipfile)
  fprintf('Reading %s\n',obj.cipfile{ii})
  fin = fopen(obj.cipfile{ii},'r','ieee-be');
  data = fread(fin,'ubit2=>uint8');
  fclose(fin);

% Find the start index, time, and number of slices for each particle
  disp('Calling cipindex')
  [idx,sod,ns]=obj.cipindex(data);
  disp('Writing to the 2D file');

% Convert two bit values to one bit
  data = data > 1;

% CIP image data are on a 12 hour clock
  delt  = csvsod(1) - sod(1);
  if delt > 7*3600 && delt < 17*3600; sod = sod + 12*3600; end
% Convert the second of the day to matlab time
  dnum  = dt + sod/86400;
% Construct the timing words
  tword = timing(sod',tmask);

% Interpolate the true airspeeds from the CSV files for each particle
  tas   = interp1(csvsod,csvtas,sod);
  
% Loop through each CIP particle
  jj = 1;
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
    nrem = 1025-jj;
    if nw > nrem
% Write out what fits
      rec(jj:1024) = img(1:nrem);
% Write out PMS records that are before this CIP record
      while ipms <= npms && pmstm(ipms) < dnum(i)
        fwrite(f2d,pms(:,ipms),'uint16');
        ipms = ipms + 1;
      end
      recout(f2d,id,dnum(i),tas(i),rec);
      
% Save the rest of the particle
      rec(1:nw-nrem) = img(nrem+1:end);
      jj = nw-nrem+1;
    else
% It all fits, stuff it in
      rec(jj:jj+nw-1) = img;
      jj = jj + nw;
    end
  end
end

% Write out the rest of the PMS records
if ipms < npms; fwrite(f2d,pms(:,ipms:npms),'uint16'); end
fclose(f2d);

function recout(fout,id,daten,tas,rec)  
% RECOUT - writes a particle record to file
% 
% recout(fout,id,daten,tas,rec)
%  fout  - output file id
%  id    - record identifier (C5)
%  daten - matlab time stamp of the last particle in the record
%  tas   - true air speed
%  rec   - 4096 byte image record
%  

% Convert the timestamp to a vector
  dv = datevec(daten);
  msec = mod(dv(6),1) * 1000;
  ovld = 0;

% Write out the record header
  fwrite(fout, ...
      [id,dv(4),dv(5),floor(dv(6)),dv(1),dv(2),dv(3),...
        tas,msec,ovld], 'uint16');
% Write out the image data
  fwrite(fout,rec,'uint32');

function tword = timing(dsec,tmask)
% TIMING - Create the timing word
%
% timing(sod,tmask)
%   sod   - second of the day for this particle
%   tmask - timing work pattern that indicates that it is a timing word
%     0xAAAAAA0000000000
  dsec = dsec * 12E6;
% 4294967296 is 2^32
  tword = [bitor(uint32(mod(dsec/4294967296,16)),tmask); ...
           uint32(mod(dsec,4294967296))];


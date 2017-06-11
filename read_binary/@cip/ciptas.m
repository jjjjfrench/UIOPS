function [timestamp,tas, date] = ciptas(cipdir, csvfiles)
% CIPTAS - read the true air speed from the CIP csv files
%
% [timestamp,tas,date] = ciptas(cipdir, csvfiles)
%
% csvfiles - list of csv files to read
%
% timestamp - the matlab time of each record
% tas       - the true airspeed from each record
%

sod = [];
tas = [];
date = -1;

% Loop through each file
fprintf('Reading CSV files.\n')
for ii = 1:length(csvfiles)
  fprintf('%d %s\n', ii, [cipdir, csvfiles(ii).name]);
  fid = fopen([cipdir, csvfiles(ii).name],'r');

% Skip the header lines
  line = '';
  while ischar(line) && isempty(strfind(line,'***')); line = fgetl(fid); end

% Split the column headers
  line = fgetl(fid);
  columns = regexp(line, ',', 'split');
  ncol = length(columns);

% Look for the true airspeed column
  tascol = find(strcmp('True Air Speed',columns));

% Read in the data
  csv = textscan(fid,'%f','Delimiter',',');
  csv = reshape(csv{1},ncol,length(csv{1})/ncol);
  fclose(fid);

% Get time and tas
  sod = [sod csv(1,:)];
  tas = [tas csv(tascol,:)];
end

% Determine the date
[~,f] = fileparts([cipdir, csvfiles(1).name]);
ymdh=textscan(f,'00CIP Grayscale%4d%2d%2d%2d');
darr=double(cell2mat(ymdh));
hh=darr(4);
darr(4:6) = 0;
date = datenum(darr);
if hh==0 && sod(1) > 86400
  fprintf('Deleting a day from the time stamps, sod(1)=%f\n',sod(1));
  sod = sod - 86400;
end
timestamp = date + sod/86400;

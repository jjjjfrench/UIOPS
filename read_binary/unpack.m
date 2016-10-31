function unpack(obj)
% UNPACK - unpack the files in the CIP object
%
% Note: the unpacked file names with path are set by the object constructor

unpackfl = false;

% Create the names of the unpacked files and set a flag if one
% of them doesn't exist.
for ii=1:obj.nfiles
  if ~exist(obj.cipfile{ii},'file'); unpackfl = true; end
end

% At least one file is not found.  Start the parallel computing
% toolbox and unpack the files.
if unpackfl
  fprintf('Need to unpack files\n');
  
  % get the last byte of the previous file
  lastbyte = zeros(obj.nfiles,1);
  for ii = 1:obj.nfiles-1
    fid = fopen([obj.cipdir, obj.packedcip(ii).name]);
    dl=obj.packedcip;
    for jj = 1:dl(1).bytes
      fseek(fid,-jj,'eof');
      b=fread(fid,1,'*uint8');
      % if the highest bit is set, this is a repeat sequence, try again
      if b < 128; break; end
    end
    fclose(fid);
    if b > 63      % Three values
      lastbyte(ii+1) = mod(b,4);
    elseif b > 31  % Two values
      lastbyte(ii+1) = mod(bitshift(b,-2),4);
    else           % One value
      lastbyte(ii+1) = mod(bitshift(b,-4),4);
    end
  end
  
  % Try to parallelize the process
  parobj = gcp('nocreate');
%  if obj.nfiles > 1
%   if matlabpool('size') == 0
%    if isempty(parobj);
%      try
%       matlabpool(min([obj.nfiles,feature('numCores'),12]));
%        parobj = parpool(min([obj.nfiles,feature('numCores'),12]));
%      catch ME
%        disp('Unable to use the Parallel Computing Toolbox');
%        disp('Running single threaded');
%      end
%    end
%  end
  tic;
  for ii = 1:obj.nfiles
    rawcip  = [obj.cipdir, obj.packedcip(ii).name];
    cipfile = [obj.cipfile{ii}];
    if ~exist(cipfile,'file')
      fprintf('cipunp(%s,%s,%d);\n',rawcip,cipfile,lastbyte(ii));
% Unpack the data
      obj.cipunp(rawcip,cipfile,lastbyte(ii));
      fprintf('Finshed: %d\n',ii);
    end
  end
  toc;
  % Close out the parallel computing toolbox
  if ~isempty(parobj); delete(parobj); end
end

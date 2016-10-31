classdef cip
  %CIP Process CIP data
  %
  %
  
  properties
    packedcip = {};
    csvfile   = {};
    cipfile   = {};
    cipdir = {};
    unpdir = {};
    nfiles    = 0;
  end
  
  methods
    write2d(obj,filebase)
  end
  
  methods (Static)
    cipunp(infile,outfile,lastbyte)
    [idx,sod,ns,cnt] = cipindex(cipfile)
    [sod,tas,date] = ciptas(cipfile, csvfiles)
  end
  
  methods
    function obj = cip(cipdir,unpdir)
      % CIP - create a CIP object
      %
      % cipdir - The name of the directory to recursively search for
      %   Imagefile_* and '00CIP Grayscale[0-9].csv files
      %   If cipdir is a file name rather than a directory, it is
      %   assigned to packedcip and the directory that contains it
      %   is searched for csv files.
      if isdir(cipdir)
        obj.packedcip = dir([cipdir,'Imagefile_*']);
      elseif exist(cipdir,'file')
        obj.packedcip{1} = cipdir;
% Get the directory the file is in
        cipdir = fileparts(cipdir);
      end
      obj.nfiles = length(obj.packedcip);
      obj.cipdir = cipdir;
      % Create the names for the unpacked files
      if nargin == 1
        unpdir = '.';
      else
        if ~isdir(unpdir); mkdir(unpdir); end
      end
      for ii=1:obj.nfiles
        [~,f] = fileparts(obj.packedcip(ii).name);
        obj.cipfile{ii} = fullfile(unpdir,[strrep(f,'Imagefile_',''), '.cip']);
      end
      obj.unpdir = unpdir;
      % Get the names of the CSV files
      obj.csvfile = dir([cipdir,'00CIP Gray*.csv']);
    end
  end
end


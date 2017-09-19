function cip_obj_to_netcdf(obj, outfile)



% Read the CIP csv data
[timestamp,csvtas, dt] = obj.ciptas(obj.cipdir, obj.csvfile);
timestamp = timestamp - datenum(dt); %Get just datenum format of corresponding sod referenced from first day
csvsod = timestamp*86400.; %Convert to seconds from date number format


% The probe ID for the CIP is set to C5 because xpms2d has a particular
% format for the timing word that is constructed here
% 0xAAAAAAxxxxxxxxxx, where the time part is the number of 12 microsec
% clicks since UTC midnight.

tmask = uint32(hex2dec('AAAAAA00'));
ipms  = 1;

% Create netCDF file 
f = netcdf.create(outfile, 'clobber');
    
    dimid0 = netcdf.defDim(f,'time',netcdf.getConstant('NC_UNLIMITED'));
    dimid1 = netcdf.defDim(f,'ImgRowlen',64);
    dimid2 = netcdf.defDim(f,'ImgBlocklen',512);
    
    varid0 = netcdf.defVar(f,'year', 'double', dimid0);
    varid1 = netcdf.defVar(f,'month','double',dimid0);
    varid2 = netcdf.defVar(f,'day','double',dimid0);
    varid3 = netcdf.defVar(f,'hour','double',dimid0);
    varid4 = netcdf.defVar(f,'minute','double',dimid0);
    varid5 = netcdf.defVar(f,'second','double',dimid0);
    varid6 = netcdf.defVar(f,'millisec','double',dimid0);
    
    varid8 = netcdf.defVar(f,'data','double',[dimid1 dimid2 dimid0]);
    netcdf.endDef(f)
date_vec = datevec(dt);      
year = date_vec(1);
month = date_vec(2);
day = date_vec(3);
% Open and read each file of unpacked cip images
index = 1;

for ii = 1:length(obj.cipfile)
  fprintf('Reading %s\n',obj.cipfile{ii})
  fin = fopen(obj.cipfile{ii},'r','ieee-be');
  data = fread(fin,'ubit2=>uint8');
  fclose(fin);
  particle_index = 1;
% Find the start index, time, and number of slices for each particle
  disp('Calling cipindex')
  [idx,sod,ns]=obj.cipindex(data);
  disp('Writing to the netCDF file');

% CIP image data are on a 12 hour clock
% CSV sod have been corrected already
  delt  = csvsod(1) - sod(1);
  if delt > 7*3600 && delt < 17*3600 
      sod = sod + 12*3600.; 
  end
% Convert the second of the day to matlab date number format
  dnum  = dt + sod/86400;
  
% Interpolate the true airspeeds from the CSV files for each particle
  tas   = interp1(csvsod,csvtas,sod);
  
% Roll back HHMMSS if a flight crosses midnight  
  sod(sod>=240000) = sod(sod>=240000) - 240000;
  
% Construct 4096 byte buffer (512 pixels)
  while(particle_index < length(ns))
      len = 1;
      img_array = -1*ones(512,64);
      while(len+ns(particle_index)+1 < 512 && particle_index < length(ns))
          
         img_array(len:len+ns(particle_index)+1, :) = reshape(data(idx(particle_index):((idx(particle_index))+(ns(particle_index)+2)*64-1)), 64, ns(particle_index)+2)';
         len = len+ns(particle_index)+2;
         particle_index = particle_index+1;
      end
      hour = floor(sod(particle_index)/3600);
      minute = floor((sod(particle_index)-hour*3600)/60);
      second = floor(sod(particle_index)-hour*3600-minute*60);
      millisec = floor((sod(particle_index)-hour*3600-minute*60-second)*100);
      disp(['Writing frame ' num2str(index)]);
      % Write buffer
      netcdf.putVar ( f, varid0, index, 1, year );
      netcdf.putVar ( f, varid1, index, 1, month );
      netcdf.putVar ( f, varid2, index, 1, day );
      netcdf.putVar ( f, varid3, index, 1, hour );
      netcdf.putVar ( f, varid4, index, 1, minute );
      netcdf.putVar ( f, varid5, index, 1, second );
      netcdf.putVar ( f, varid6, index, 1, millisec );

      netcdf.putVar ( f, varid8, [0, 0, index], [64,512,1], img_array' );
      index = index+1;
  end    
end    
netcdf.close(f);

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

function raw_cip_to_cdf(cipdatapath,outdatapath,outfilename)

%FIRST DELETE CAL AND SONIC CSV FILES FROM CIP DATETIME FOLDER

%this script extracts raw cip files from specified location and outputs
%a netcdf file

%example file paths 
%cipdatapath = '/kingair_data/pacmice16/cip/20160818/20160818143905/'
%outdatapath = '/kingair_data/pacmice16/cip/20160818/cip_20160818'
%outfilename = 'DIMG.20160818.cip.cdf'
p = path;
cdir = pwd;
path(p,[cdir,'/@cip']);
obj = cip(cipdatapath,outdatapath)

unpack(obj)

cip_obj_to_netcdf(obj,[outdatapath,'/',outfilename])
path(p);

end
function runSizeDist(date,probe,project) %eventually the IA threshold should be passed here
%Automatically pulls the proper nc and autoanalysis files to generate size
%distributions and then concatenate them
%CAUTION: will not work for dates that have a/b/c's or _1/2/3 in the
%directory name
%
% date - 'YYMMDD'
% probe - '2DS/CIP/etc'
% project = 'SNOWIE/PACMICE'
switch project
    case 'SNOWIE'
        ncfile = ['/kingair_data/snowie17/work/20',date,'.c1.nc'];
    case 'PACMICE'
        
end

%use below for flight data
main_nc = netcdf.open(ncfile);
timesec = netcdf.getVar(main_nc, netcdf.inqVarID(main_nc, 'time'));
tas = netcdf.getVar(main_nc, netcdf.inqVarID(main_nc, 'tas'));
netcdf.close(main_nc);
days = floor(timesec/86400);
hours = floor(mod(timesec,86400)/3600);
minutes = floor(mod(timesec,3600)/60);
seconds = mod(timesec,60);
timehhmmss = int32(seconds+minutes*100+hours*10000);
length(timehhmmss)
length(tas)

%[time, tas, dt] = cip_obj.ciptas(cip_obj.cipdir, cip_obj.csvfile);
%timehhmmss = str2num(datestr(time, 'HHMMSS'));

pres = NaN*zeros(size(tas));
temp1 = NaN*zeros(size(tas));
inst = 'TEST';

switch probe
    case '2DS'
        filedir = ['/kingair_data/snowie17/2DS/20',date,'/'];
        
        %Generate V channel size dists for day
        files = dir([filedir,'cat.DIMG.base',date,'*.2DS.V.proc.cdf']);
        filenums = length(files);

        for i=1:filenums
            inFile = [filedir,files(i).name];
            outFile = [filedir,'SD.',files(i).name];
            sizeDistNew(inFile,outFile,tas,floor(timehhmmss),probe,6,0,pres,temp1,project,['20',date]);
        end
        if (filenums>1)
            catDist([filedir,'SD.cat.DIMG.base',date,'*.2DS.V.proc.cdf']); 
        end

        %Generate H channel size dists for day
        files = dir([filedir,'cat.DIMG.base',date,'*.2DS.H.proc.cdf']);
        filenums = length(files);

        for i=1:filenums
            inFile = [filedir,files(i).name];
            outFile = [filedir,'SD.',files(i).name];
            sizeDistNew(inFile,outFile,tas,floor(timehhmmss),probe,6,0,pres,temp1,project,['20',date]);
        end
        if (filenums>1)
            catDist([filedir,'SD.cat.DIMG.base',date,'*.2DS.H.proc.cdf']);
        end
    case 'CIP'
        filedir = ['/kingair_data/snowie17/cip/20',date,'/cip_20',date,'/'];
        files = dir([filedir,'cat.20',date,'*_cip.proc.cdf']);
        filenums = length(files);
        
        for i=1:filenums
            inFile = [filedir,files(i).name];
            outFile = [filedir,'SD.',files(i).name];
            sizeDistNew(inFile,outFile,tas,floor(timehhmmss),probe,6,0,pres,temp1,project,['20',date]);
        end
        if (filenums > 1)
            catDist([filedir,'SD.cat.20',date,'*_cip.proc.cdf']);
        end
    case '2DP'

    case '2DC'

end

end

function runSizeDist(date,probe,project) %eventually the IA threshold should be passed here
%Automatically pulls the proper nc and autoanalysis files to generate size
%distributions and then concatenates them
%CAUTION: will not work for dates that have a/b/c's or _1/2/3 in the
%directory name
%
% date - 'YYMMDD'
% probe - '2DS/CIP/etc'
% project = 'SNOWIE/PACMICE'
switch project
    case 'SNOWIE'
        ncfile = ['/kingair_data/snowie17/work/20',date,'.c1.nc'];
        projdir = '/kingair_data/snowie17/';
        main_nc = netcdf.open(ncfile);
        timesec = netcdf.getVar(main_nc, netcdf.inqVarID(main_nc, 'time'), 'double');
        tas = netcdf.getVar(main_nc, netcdf.inqVarID(main_nc, 'tas'),'double');
        netcdf.close(main_nc);
        days = floor(timesec/86400);
        hours = floor(mod(timesec,86400)/3600);
        minutes = floor(mod(timesec,3600)/60);
        seconds = mod(timesec,60);
        timehhmmss = double(seconds+minutes*100+hours*10000); 
    case 'PACMICE'
        ncfile = ['/kingair_data/pacmice16/work/20',date,'.c1.nc'];
        projdir = '/kingair_data/pacmice16/';
        main_nc = netcdf.open(ncfile);
        timehhmmss = netcdf.getVar(main_nc, netcdf.inqVarID(main_nc, 'TIME'), 'double');
        tas = netcdf.getVar(main_nc, netcdf.inqVarID(main_nc, 'tas'),'double');
        netcdf.close(main_nc);
end

%use below for flight data

length(timehhmmss)
length(tas)

%[time, tas, dt] = cip_obj.ciptas(cip_obj.cipdir, cip_obj.csvfile);
%timehhmmss = str2num(datestr(time, 'HHMMSS'));

pres = NaN*zeros(size(tas));
temp1 = NaN*zeros(size(tas));
inst = 'TEST';

switch probe
    case '2DS'
        filedir = [projdir,'2DS/20',date,'/'];
        
        %Generate V channel size dists for day
        if (timehhmmss(1)>timehhmmss(end)) 
            files = dir([filedir,'cat.DIMG.base',date,'*.2DS.V.proc.cdf']); 
        else
            files = dir([filedir,'cat.DIMG.base',date(1:4),'*.2DS.V.proc.cdf']);
        end
        filenums = length(files);

        for i=1:filenums
            inFile = [filedir,files(i).name];
            outFile = [filedir,'SD.',files(i).name];
            sizeDist(inFile,outFile,tas,floor(timehhmmss),probe,6,0,pres,temp1,project,['20',date]);
        end
        if (filenums>1)
            if (timehhmmss(1)>timehhmmss(end)) 
                catDist([filedir,'SD.cat.DIMG.base',date,'*.2DS.V.proc.cdf']);
            else
                catDist([filedir,'SD.cat.DIMG.base',date(1:4),'*.2DS.V.proc.cdf']);
                system(['mv ',filedir,'SD.cat.DIMG.base',date(1:4),'.2DS.V.proc.cdf ',filedir,filedir,'SD.cat.DIMG.base',date,'.2DS.V.proc.cdf']);
            end
        end

        %Generate H channel size dists for day
        files = dir([filedir,'cat.DIMG.base',date,'*.2DS.H.proc.cdf']);
        filenums = length(files);

        for i=1:filenums
            inFile = [filedir,files(i).name];
            outFile = [filedir,'SD.',files(i).name];
            sizeDist(inFile,outFile,tas,floor(timehhmmss),probe,6,0,pres,temp1,project,['20',date]);
        end
        if (filenums>1)
            catDist([filedir,'SD.cat.DIMG.base',date,'*.2DS.H.proc.cdf']);
        end
    case 'CIPG'
        filedir = [projdir,'cip/20',date,'/cip_20',date,'/'];
        files = dir([filedir,'cat.DIMG.20',date,'*.cip.proc.cdf']);
        filenums = length(files);
        
        for i=1:filenums
            inFile = [filedir,files(i).name];
            outFile = [filedir,'SD.',files(i).name];
            sizeDist(inFile,outFile,tas,floor(timehhmmss),'CIP',6,0,pres,temp1,project,['20',date]);
        end
        if (filenums > 1)
            catDist([filedir,'SD.cat.DIMG.20',date,'*.cip.proc.cdf']);
        end
    case '2DP'
        filedir = [projdir,'2DP/20',date,'/'];
        inFile = [filedir,'DIMG.20',date,'.2d.2dp.proc.cdf'];
        outFile = [filedir,'SD.DIMG.20',date,'.2d.2dp.proc.cdf'];
        sizeDist(inFile,outFile,tas,floor(timehhmmss),probe,6,0,pres,temp1,project,['20',date]);
    case '2DC'
        filedir = [projdir,'2DP/20',date,'/'];
        inFile = [filedir,'DIMG.20',date,'.2d.2dc.proc.cdf'];
        outFile = [filedir,'SD.DIMG.20',date,'.2d.2dc.proc.cdf'];
        sizeDist(inFile,outFile,tas,floor(timehhmmss),probe,6,0,pres,temp1,project,['20',date]);
end

end

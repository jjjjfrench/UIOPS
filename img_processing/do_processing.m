function do_processing(basefilename,pType,nEvery,project,threshold)
%   Run in OAP_Processing/img_processing directory after calling 
%   'setenv LD_LIBRARY_PATH /kingair_data/OAP_Processing/img_processing'
%   from the command line
%   
%   Example function call:
%   do_processing('kingair_data/pacmice16/2DS/20161101/base*.2DS','2DS',8,'PACMICE',50)
%   
%   Example call from the command line:
%   matlab -nodisplay -r "do_processing('dir/foo.2DS','2DS',8,'PACMICE',50)"
%
%   -Adam Majewski, 11/8/2015
%
    p = path; %current library search path
    cdir = pwd; %present directory
    slashpos = find(cdir == '/',1,'last');
    pdir = cdir(1:slashpos-1);
    %pdir = '/kingair_data/OAP_Processing';
    
    starpos = find(basefilename == '*',1,'last');
    slashpos = find(basefilename == '/',1,'last');
    files = dir(basefilename);
    filenums = length(files);
    filedir = basefilename(1:slashpos);
    logname = [filedir,'log.txt']
    logid = fopen(logname,'w')
    fprintf(logid,'started: %s\r\n',datestr(now));
    
    switch pType
        case '2DC'
%pms
            if ~exist([basefilename(1:slashpos),'DIMG.',basefilename(slashpos+1:end),'.2dc.cdf'],'file')
                path(p,[pdir,'/read_binary']); %add read_binary subdirectory to search path
                fprintf(logid,'read_binary: %s\r\n',datestr(now));
                read_binary_PMS(basefilename,'1');
                
                path(p,[pdir,'/img_processing']); %add img_processing subdirectory to search path
            end
            
           
            fprintf(logid,'imgProc: %s\r\n',datestr(now));
            files = dir([filedir,'DIMG.*.2dc.cdf']);
            for i=1:length(files)
                perpos = find(files(i).name == '.', 1, 'last');
                runImgProc([filedir,files(i).name],pType,nEvery,project,threshold);
                if i > 1
                    mergeNetcdf([filedir,files(i).name(1:perpos-1),'*.proc',files(i).name(perpos:end)]);
                end
            end
        case '2DP'
%pms
            if ~exist([basefilename(1:slashpos),'DIMG.',basefilename(slashpos+1:end),'.2dp.cdf'],'file')
                path(p,[pdir,'/read_binary']); %add read_binary subdirectory to search path
                fprintf(logid,'read_binary: %s\r\n',datestr(now));
                read_binary_PMS(basefilename,'1');
                
                path(p,[pdir,'/img_processing']); %add img_processing subdirectory to search path
            end
                
            
            fprintf(logid,'imgProc: %s\r\n',datestr(now));
            files = dir([filedir,'DIMG.*.2dp.cdf']);
            for i=1:length(files)
                perpos = find(files(i).name == '.', 1, 'last');
                runImgProc([filedir,files(i).name],pType,nEvery,project,threshold);
                if i > 1
                    mergeNetcdf([filedir,files(i).name(1:perpos-1),'*.proc',files(i).name(perpos:end)]);
                end
            end
        case 'CIP'
            %read_binary_DMT
            
        case 'CIPG'
            %given basefilename in format /projectYY/cip/YYYYMMDD/YYYYMMDDHHMMSS/
            cipslash = find(basefilename == '/',3,'last');
            cipdir = basefilename(1:cipslash(2)); %Grabs the cip directory name
            %ciptime = basefilename(cipslash(2)+1:cipslash(2)+9); 
            ciptime = basefilename(cipslash(1)+1:cipslash(2)-1); %Grabs the date from the directory name
            path(p,[pdir,'/read_binary']); %add read_binary subdirectory to search path
            fprintf(logid,'raw_cip_to_cdf: %s\r\n',datestr(now));
            raw_cip_to_cdf(basefilename,[cipdir,'cip_',ciptime],['DIMG.',ciptime,'.cip.cdf']);
            cip_dimg = [cipdir,'cip_',ciptime,'/','DIMG.',ciptime,'.cip.cdf'];
            
            path(p,[pdir,'/img_processing']); %add img_processing subdirectory to search path
            fprintf(logid,'imgProc: %s\r\n',datestr(now));
            runImgProc(cip_dimg,pType,nEvery,project,threshold);
            
            fprintf(logid,'mergeNetcdf: %s\r\n',datestr(now));
            mergeNetcdf([cip_dimg(1:end-4),'*.proc',cip_dimg(end-3:end)]);
            
        case 'PIP'
%dmt

        case 'HVPS'
%spec

        case '2DS'
            for i=1:filenums
                fprintf(logid,'read_binary: %s\r\n',datestr(now));
                path(p,[pdir,'/read_binary']); %add read_binary subdirectory to search path
                read_binary_SPEC([filedir,files(i).name],'1');
                
                fprintf(logid,'imgProc: %s\r\n',datestr(now));
                path(p,[pdir,'/img_processing']); %add img_processing subdirectory to search path
                runImgProc([filedir,'DIMG.',files(i).name,'*.cdf'],pType,nEvery,project,threshold);
                
                fprintf(logid,'mergeNetcdf H: %s\r\n',datestr(now));
                mergeNetcdf([filedir,'DIMG.',files(i).name,'.H*.proc.cdf']);
                fprintf(logid,'mergeNetcdf V: %s\r\n',datestr(now));
                mergeNetcdf([filedir,'DIMG.',files(i).name,'.V*.proc.cdf']);
            end
            
    end
    fprintf(logid,'finished: %s\r\n',datestr(now));
    path(p);
    fclose(logid);
end

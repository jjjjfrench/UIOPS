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
    
    switch pType
        case '2DC'
%pms
%needed for our processing

        case '2DP'
%pms
%needed for our processing

        case 'CIP'
            %read_binary_DMT
            
        case 'CIPG'
            %given basefilename in format /projectYY/cip/YYYYMMDD/YYYYMMDDHHMMSS/
            cipslash = find(basefilename == '/',2,'last');
            cipdir = basefilename(1:cipslash(2)); %Grabs the cip directory name
            ciptime = basefilename(cipslash(2)+1:cipslash(2)+9); %Grabs the date from the directory name
            path(p,[pdir,'/read_binary']); %add read_binary subdirectory to search path
            raw_cip_to_cdf(basefilename,[cipdir,'cip_',ciptime],[ciptime,'_cip.cdf']);
            path(p,[pdir,'/img_processing']); %add img_processing subdirectory to search path
            runImgProc([ciptime,'_cip.cdf'],pType,nEvery,project,threshold);
            mergeNetcdf([cipdir,'cip_',ciptime,'/',ciptime,'_cip*.proc.cdf']);
        case 'PIP'
%dmt

        case 'HVPS'
%spec

        case '2DS'

            for i=1:filenums
                path(p,[pdir,'/read_binary']); %add read_binary subdirectory to search path
                read_binary_SPEC([filedir,files(i).name],'1');
                path(p,[pdir,'/img_processing']); %add img_processing subdirectory to search path
                runImgProc([filedir,'DIMG.',files(i).name,'*.cdf'],pType,nEvery);
                mergeNetcdf([filedir,'DIMG.',files(i).name,'.H*.proc.cdf']);
                mergeNetcdf([filedir,'DIMG.',files(i).name,'.V*.proc.cdf']);
            end

    end
    path(p)
end
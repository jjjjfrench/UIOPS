function status = mergeNetcdf(infilename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Merges netcdf files specified by infilename as either a list of filenames
% or a single filename with a wildcard that references multiple files.
% Outfilename generated from either the first filename or the filename
% prior to the wildcard symbol
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    starpos = find(infilename == '*',1,'last');
    slashpos = find(infilename == '/',1,'last');
    files = dir(infilename);
    filenums = length(files);
    filedir = infilename(1:slashpos);
    filestr = '';
    
    outfilename = [filedir,'cat.',files(1).name];
    
    if ~isempty(starpos)
        filestr = infilename;
        outfilename = [filedir,'cat.',infilename(slashpos+1:starpos-1),infilename(starpos+1:length(infilename))];
    else
        for i=1:filenums
            filestr = [filestr,' ',files(i).name];
        end
    end
    systemcall = ['ncrcat -O ',filestr,' ',outfilename];
    status = system(systemcall);
    switch status
        case 0
            disp('Files concatenated successfully');
            %status1 = system(['chmod 444 ',outfilename]);
            status1 = system(['rm ',infilename]);
            %status1 = system(['mv ',outfilename,' ',outfilename(strfind(outfilename,'cat.')+4:length(outfilename))]);
            %status1 = system('n');
            %status1 = system(['chmod 775 ',outfilename]);
        otherwise
            disp('Error');
    end
end

function runImgProc(infilename, pType, nChucks, projectname, threshold)

starpos = find(infilename == '*',1,'last');
slashpos = find(infilename == '/',1,'last');

if ~isempty(starpos)
    files = dir(infilename);
    filenums = length(files);
    %filedir = infilename(1:starpos-1);
    filedir = infilename(1:slashpos);
else
    filenums = 1;
end

for i = 1:filenums
    if filenums > 1 || ~isempty(starpos)
        infilename = [filedir,files(i).name];
    end
    
    %  nChuck*nEvery should equal the total frame number 
    ncid = netcdf.open(infilename,'nowrite');
    time = netcdf.getVar(ncid, netcdf.inqVarID(ncid,'day'));
    nEvery = ceil(length(time)/nChucks);
    netcdf.close(ncid);
    numb=11:10+nChucks;  % Start from 11 to avoid sigle numbers in file name for later convinience

    % Assign the number of CPUs for this program
    parpool(8)        % Assign n CPUs to process

    % Choose the start and end of chucks to be processed. Remember you can
    % split the chucks into different programs to process, since matlabpool can
    % only use 8 CPUs at once
    for iii=1:nChucks % 33:40  % iiith chuck will be processed 
        perpos = find(infilename == '.',1,'last');
        outfilename = [infilename(1:perpos-1),'_',num2str(iii),'.proc.cdf'];
        %outfile = ['./HVPSFAST/proc2.TEST_debug.HVPS' num2str(numb(iii)) '.cdf'];			% Output image autoanalysis file
        imgProc_sm(infilename,outfilename, pType, iii, nEvery, projectname, threshold);  % See imgprocdm documentation for more information
    end

    delete(gcp)
end
end


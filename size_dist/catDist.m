function catDist(basefilename)
%Filename should be of format /dir/HHMMSS*.2DS.H/V.SD.CDF
%Grab matching .SD.cdf files

starpos = find(basefilename == '*',1,'last');
slashpos = find(basefilename == '/',1,'last');
files = dir(basefilename);
filenums = length(files);
filedir = basefilename(1:slashpos);
outfile = [filedir,basefilename(slashpos+1:starpos-1),basefilename(starpos+1:end)];

%Add variables for the matching size distribution files along the time
%dimension
i = 1;
    in_cdf = netcdf.open([filedir,files(i).name], 'nowrite')
    timehhmmss = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'time'));
    binmin = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'bin_min'));
    binmid = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'bin_mid'));
    binmax = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'bin_max'));
    bindD = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'bin_dD'));
    conc_minR = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'conc_minR'));
    conc_AreaR = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'conc_AreaR'));
    conc_AreaDist = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'area'));
    n = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'n'));
    area =  netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'total_area'));
    one_sec_ar = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'ar'));
    iwc = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'mass'));
    habitsd = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'habitsd'));
    re = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 're'));
    iwcbl = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'massBL'));
    rejratio = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'Reject_ratio'));
    vt = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'vt'));
    pr = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'Prec_rate'));
    habitmsd = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'habitmsd'));
    %corrfactor = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'corrfactor'));
netcdf.close(in_cdf);    
for i=2:filenums
    in_cdf = netcdf.open([filedir,files(i).name], 'nowrite')
    temp_n = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'n'));
    indicies = find(temp_n > 0);
    temp_conc_minR = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'conc_minR'));
    temp_conc_AreaR = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'conc_AreaR'));
    temp_conc_AreaDist = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'area'));
    temp_area =  netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'total_area'));
    temp_iwc = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'mass'));
    temp_habitsd = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'habitsd'));
    temp_re = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 're'));
    temp_iwcbl = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'massBL'));
    temp_rejratio = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'Reject_ratio'));
    temp_vt = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'vt'));
    temp_pr = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'Prec_rate'));
    temp_habitmsd = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'habitmsd'));
    %temp_corrfactor = netcdf.getVar(in_cdf, netcdf.inqVarID(in_cdf, 'corrfactor'));
    conc_minR(:,indicies) = temp_conc_minR(:,indicies);
    conc_AreaR(:,indicies) =  temp_conc_AreaR(:,indicies);
    conc_AreaDist(:,:,indicies) = temp_conc_AreaDist(:,:,indicies);
    n(indicies) = temp_n(indicies);
    area(:,indicies) = temp_area(:,indicies);
    iwc(indicies) = temp_iwc(indicies);
    habitsd(:,:,indicies) = temp_habitsd(:,:,indicies);
    re(indicies) = temp_re(indicies);
    iwcbl(indicies) = temp_iwcbl(indicies);
    rejratio(indicies) = temp_rejratio(indicies);
    vt(indicies) = temp_vt(indicies);
    pr(indicies) = temp_pr(indicies);
    habitmsd(:,:,indicies) = temp_habitmsd(:,:,indicies);
    %corrfactor(indicies) = temp_corrfactor(indicies);
    netcdf.close(in_cdf);
end

mainf = netcdf.create(outfile, 'clobber');

% Define Dimensions
dimid0 = netcdf.defDim(mainf,'CIPcorrlen',length(binmin));
dimid1 = netcdf.defDim(mainf,'CIParealen',length(conc_AreaDist(:,1,1)));
dimid2 = netcdf.defDim(mainf,'Time',length(timehhmmss));
dimid3 = netcdf.defDim(mainf,'Habit',length(habitsd(:,1,1)));

% Define Variables
varid0 = netcdf.defVar(mainf,'time','double',dimid2); 
netcdf.putAtt(mainf, varid0,'units','HHMMSS');
netcdf.putAtt(mainf, varid0,'name','Time');

varid1 = netcdf.defVar(mainf,'bin_min','double',dimid0); 
netcdf.putAtt(mainf, varid1,'units','millimeter');
netcdf.putAtt(mainf, varid1,'long_name','bin minimum size');
netcdf.putAtt(mainf, varid1,'short_name','bin min');

varid2 = netcdf.defVar(mainf,'bin_max','double',dimid0); 
netcdf.putAtt(mainf, varid2,'units','millimeter');
netcdf.putAtt(mainf, varid2,'long_name','bin maximum size');
netcdf.putAtt(mainf, varid2,'short_name','bin max');

varid3 = netcdf.defVar(mainf,'bin_mid','double',dimid0); 
netcdf.putAtt(mainf, varid3,'units','millimeter');
netcdf.putAtt(mainf, varid3,'long_name','bin midpoint size');
netcdf.putAtt(mainf, varid3,'short_name','bin mid');

varid4 = netcdf.defVar(mainf,'bin_dD','double',dimid0); 
netcdf.putAtt(mainf, varid4,'units','millimeter');
netcdf.putAtt(mainf, varid4,'long_name','bin size');
netcdf.putAtt(mainf, varid4,'short_name','bin size');

% Good (accepted) particles
varid5 = netcdf.defVar(mainf,'conc_minR','double',[dimid0 dimid2]); 
netcdf.putAtt(mainf, varid5,'units','cm-4');
netcdf.putAtt(mainf, varid5,'long_name','Size distribution using Dmax');
netcdf.putAtt(mainf, varid5,'short_name','N(Dmax)');

varid6 = netcdf.defVar(mainf,'area','double',[dimid1 dimid0 dimid2]); 
netcdf.putAtt(mainf, varid6,'units','cm-4');
netcdf.putAtt(mainf, varid6,'long_name','binned area ratio');
netcdf.putAtt(mainf, varid6,'short_name','binned area ratio');

varid7 = netcdf.defVar(mainf,'conc_AreaR','double',[dimid0 dimid2]); 
netcdf.putAtt(mainf, varid7,'units','cm-4');
netcdf.putAtt(mainf, varid7,'long_name','Size distribution using area-equivalent Diameter');
netcdf.putAtt(mainf, varid7,'short_name','N(Darea)');

varid8 = netcdf.defVar(mainf,'n','double',dimid2); 
netcdf.putAtt(mainf, varid8,'units','cm-3');
netcdf.putAtt(mainf, varid8,'long_name','number concentration');
netcdf.putAtt(mainf, varid8,'short_name','N');

varid9 = netcdf.defVar(mainf,'total_area','double',[dimid0 dimid2]); 
netcdf.putAtt(mainf, varid9,'units','mm2/cm4');
netcdf.putAtt(mainf, varid9,'long_name','projected area (extinction)');
netcdf.putAtt(mainf, varid9,'short_name','Ac');

varid10 = netcdf.defVar(mainf,'mass','double',[dimid0 dimid2]); 
netcdf.putAtt(mainf, varid10,'units','g/cm4');
netcdf.putAtt(mainf, varid10,'long_name','mass using m-D relations');
netcdf.putAtt(mainf, varid10,'short_name','mass');

varid11 = netcdf.defVar(mainf,'habitsd','double',[dimid3 dimid0 dimid2]); 
netcdf.putAtt(mainf, varid11,'units','cm-4');
netcdf.putAtt(mainf, varid11,'long_name','Size Distribution with Habit');
netcdf.putAtt(mainf, varid11,'short_name','habit SD');

varid12 = netcdf.defVar(mainf,'re','double',dimid2); 
netcdf.putAtt(mainf, varid12,'units','mm');
netcdf.putAtt(mainf, varid12,'long_name','effective radius');
netcdf.putAtt(mainf, varid12,'short_name','Re');

varid13 = netcdf.defVar(mainf,'ar','double',dimid2); 
netcdf.putAtt(mainf, varid13,'units','100/100');
netcdf.putAtt(mainf, varid13,'long_name','Area Ratio');
netcdf.putAtt(mainf, varid13,'short_name','AR');

varid14 = netcdf.defVar(mainf,'massBL','double',[dimid0 dimid2]); 
netcdf.putAtt(mainf, varid14,'units','g/cm4');
netcdf.putAtt(mainf, varid14,'long_name','mass using Baker and Lawson method');
netcdf.putAtt(mainf, varid14,'short_name','mass_BL');

varid15 = netcdf.defVar(mainf,'Reject_ratio','double',dimid2); 
netcdf.putAtt(mainf, varid15,'units','100/100');
netcdf.putAtt(mainf, varid15,'long_name','Reject Ratio');

varid16 = netcdf.defVar(mainf,'vt','double',[dimid0 dimid2]); 
netcdf.putAtt(mainf, varid16,'units','g/cm4');
netcdf.putAtt(mainf, varid16,'long_name','Mass-weighted terminal velocity');

varid17 = netcdf.defVar(mainf,'Prec_rate','double',[dimid0 dimid2]); 
netcdf.putAtt(mainf, varid17,'units','mm/hr');
netcdf.putAtt(mainf, varid17,'long_name','Precipitation Rate');

varid18 = netcdf.defVar(mainf,'habitmsd','double',[dimid3 dimid0 dimid2]); 
netcdf.putAtt(mainf, varid18,'units','g/cm-4');
netcdf.putAtt(mainf, varid18,'long_name','Mass Size Distribution with Habit');
netcdf.putAtt(mainf, varid18,'short_name','Habit Mass SD');

varid19 = netcdf.defVar(mainf,'Calcd_area','double',[dimid0 dimid2]); 
netcdf.putAtt(mainf, varid19,'units','mm^2/cm4');
netcdf.putAtt(mainf, varid19,'long_name','Particle Area Calculated using A-D realtions');
netcdf.putAtt(mainf, varid19,'short_name','Ac_calc');

%Warnign: This variable is inconsistent with later versions of sizeDist
%varid20 = netcdf.defVar(mainf,'count','double',[dimid2]); 
%netcdf.putAtt(mainf, varid20,'units','1');
%netcdf.putAtt(mainf, varid20,'long_name','number count for partial images without any correction');

netcdf.endDef(mainf);
% Output Variables

netcdf.putVar ( mainf, varid0, timehhmmss );
netcdf.putVar ( mainf, varid1, binmin );
netcdf.putVar ( mainf, varid2, binmax );
netcdf.putVar ( mainf, varid3, binmid );
netcdf.putVar ( mainf, varid4, bindD );
netcdf.putVar ( mainf, varid5, double(conc_minR) );
netcdf.putVar ( mainf, varid7, double(conc_AreaR) );
netcdf.putVar ( mainf, varid6, double(conc_AreaDist));
netcdf.putVar ( mainf, varid8, double(n));
netcdf.putVar ( mainf, varid9, double(area));
netcdf.putVar ( mainf, varid10, double(iwc));
netcdf.putVar ( mainf, varid11, habitsd);
netcdf.putVar ( mainf, varid12, re );
netcdf.putVar ( mainf, varid13, one_sec_ar );
netcdf.putVar ( mainf, varid14, double(iwcbl) );
netcdf.putVar ( mainf, varid15, rejratio );
netcdf.putVar ( mainf, varid16, double(vt) );
netcdf.putVar ( mainf, varid17, double(pr) );
netcdf.putVar ( mainf, varid18, double(habitmsd));
%netcdf.putVar ( mainf, varid20, double(corrfactor));

netcdf.close(mainf) % Close output NETCDF file
end

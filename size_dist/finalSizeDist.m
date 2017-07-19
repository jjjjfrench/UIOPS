fCDP = '/kingair_data/snowie17/processed/20170119a.c1.nc';
f2DS_H = '/kingair_data/snowie17/2DS/20170119_1/SD.cat.DIMG.base170119.2DS.H.proc.cdf';
f2DS_V = '/kingair_data/snowie17/2DS/20170119_1/SD.cat.DIMG.base170119.2DS.V.proc.cdf';
fCIP = '/kingair_data/snowie17/cip/20170119a/cip_20170119a/SD.cat.20170119a_cip.proc.cdf';
f2DP = '/kingair_data/snowie17/2DP/20170119_1/SD.DIMG.20170119a.2d.2dp_1.proc.cdf';
f2DC = '/kingair_data/snowie17/2CP/20170119_1/SD.DIMG.20170119a.2d.2dc_1.proc.cdf';
nc_CDP = netcdf.open(fCDP);
tas = netcdf.getVar(nc_CDP, netcdf.inqVarID(nc_CDP, 'tas'));
timesec = netcdf.getVar(nc_CDP, netcdf.inqVarID(nc_CDP, 'time'));
hours = floor(mod(timesec,86400)/3600);
minutes = floor(mod(timesec,3600)/60);
seconds = mod(timesec,60);
timehhmmss = int32(seconds+minutes*100+hours*10000);

%CDP
nbins_CDP = 27;
bin_min_CDP = [2., 3., 4., 5., 6., 7., 8., 10., 12., 14., 16., 18., 20., 22., 24., 26., 28., 30., 32., 34., 36., 38., 40., 42., 44., 46., 48.];%um
bin_max_CDP = [3., 4., 5., 6., 7., 8., 10., 12., 14., 16., 18., 20., 22., 24., 26., 28., 30., 32., 34., 36., 38., 40., 42., 44., 46., 48., 50.];%um
bin_mid_CDP = (bin_max_CDP + bin_min_CDP)./2.;
bin_dD_CDP = bin_max_CDP - bin_min_CDP;

CCDP = netcdf.getVar(nc_CDP, netcdf.inqVarID(nc_CDP, 'CCDP_NRB'));
total_conc_CDP = reshape(CCDP(2:28,1,:),[nbins_CDP,length(timehhmmss)]);
conc_CDP = total_conc_CDP./bin_dD_CDP';%cm-3/um
total_conc_CDP = sum(total_conc_CDP,1);

netcdf.close(nc_CDP);

nareabins = 10;


%2DS
if (exist(f2DS_H))
	%WARNING: Size dist must be generated for H every time to get bins set up even if the data will be all NaN's based on the way this is handled!
	nc_2DS_H = netcdf.open(f2DS_H);

	time_2DS = netcdf.getVar(nc_2DS_H, netcdf.inqVarID(nc_2DS_H, 'time'));

	bin_min_2DS = netcdf.getVar(nc_2DS_H, netcdf.inqVarID(nc_2DS_H, 'bin_min'));
	bin_max_2DS = netcdf.getVar(nc_2DS_H, netcdf.inqVarID(nc_2DS_H, 'bin_max'));
	bin_mid_2DS = netcdf.getVar(nc_2DS_H, netcdf.inqVarID(nc_2DS_H, 'bin_mid'));
	bin_dD_2DS = netcdf.getVar(nc_2DS_H, netcdf.inqVarID(nc_2DS_H, 'bin_dD'));

	nbins_2DS_H = length(bin_min_2DS);

	conc_2DS_H = netcdf.getVar(nc_2DS_H, netcdf.inqVarID(nc_2DS_H, 'conc_minR'));
	conc_area_2DS_H = netcdf.getVar(nc_2DS_H, netcdf.inqVarID(nc_2DS_H, 'area'));
	total_conc_2DS_H = netcdf.getVar(nc_2DS_H, netcdf.inqVarID(nc_2DS_H, 'n'));
	rej_rat_2DS_H = netcdf.getVar(nc_2DS_H, netcdf.inqVarID(nc_2DS_H, 'Reject_ratio'));

	netcdf.close(nc_2DS_H);
else
	nbins_2DS_H = 1;

	bin_min_2DS = zeros(nbins_2DS_H)*NaN;
	bin_max_2DS = zeros(nbins_2DS_H)*NaN;
	bin_mid_2DS = zeros(nbins_2DS_H)*NaN;
	bin_dD_2DS = zeros(nbins_2DS_H)*NaN;

	conc_2DS_H = zeros(nbins_2DS_H,length(tas))*NaN;
	conc_area_2DS_H = zeros(nareabins,nbins_2DS_H,length(tas))*NaN;
	total_conc_2DS_H = zeros(length(tas),1)*NaN;
	rej_rat_2DS_H = zeros(length(tas),1)*NaN;
end

if (exist(f2DS_V))
        nc_2DS_V = netcdf.open(f2DS_V);

        nbins_2DS_V = length(bin_min_2DS);

        conc_2DS_V = netcdf.getVar(nc_2DS_V, netcdf.inqVarID(nc_2DS_V, 'conc_minR'));
        conc_area_2DS_V = netcdf.getVar(nc_2DS_V, netcdf.inqVarID(nc_2DS_V, 'area'));
        total_conc_2DS_V = netcdf.getVar(nc_2DS_V, netcdf.inqVarID(nc_2DS_V, 'n'));
        rej_rat_2DS_V = netcdf.getVar(nc_2DS_V, netcdf.inqVarID(nc_2DS_V, 'Reject_ratio'));

	netcdf.close(nc_2DS_V);
else
        nbins_2DS_V = length(bin_min_2DS);
    
        conc_2DS_V = zeros(nbins_2DS_V,length(tas))*NaN;
        conc_area_2DS_V = zeros(nareabins,nbins_2DS_V,length(tas))*NaN;
        total_conc_2DS_V = zeros(length(tas),1)*NaN;
        rej_rat_2DS_V = zeros(length(tas),1)*NaN;
end

%CIP
if(exist(fCIP))	
	nc_CIP = netcdf.open(fCIP);

	bin_min_CIP = netcdf.getVar(nc_CIP, netcdf.inqVarID(nc_CIP, 'bin_min'));
	bin_max_CIP = netcdf.getVar(nc_CIP, netcdf.inqVarID(nc_CIP, 'bin_max'));
	bin_mid_CIP = netcdf.getVar(nc_CIP, netcdf.inqVarID(nc_CIP, 'bin_mid'));
	bin_dD_CIP = netcdf.getVar(nc_CIP, netcdf.inqVarID(nc_CIP, 'bin_dD'));
	nbins_CIP = length(bin_min_CIP);

	conc_CIP = netcdf.getVar(nc_CIP, netcdf.inqVarID(nc_CIP, 'conc_minR'));
	conc_area_CIP = netcdf.getVar(nc_CIP, netcdf.inqVarID(nc_CIP, 'area'));
	total_conc_CIP = netcdf.getVar(nc_CIP, netcdf.inqVarID(nc_CIP, 'n'));
	rej_rat_CIP = netcdf.getVar(nc_CIP, netcdf.inqVarID(nc_CIP, 'Reject_ratio'));

	netcdf.close(nc_CIP);
else
        nbins_CIP = 1;

        bin_min_CIP = zeros(nbins_CIP)*NaN;
        bin_max_CIP = zeros(nbins_CIP)*NaN;
        bin_mid_CIP = zeros(nbins_CIP)*NaN;
        bin_dD_CIP = zeros(nbins_CIP)*NaN;

        conc_CIP = zeros(nbins_CIP,length(tas))*NaN;
        conc_area_CIP = zeros(nareabins,nbins_CIP,length(tas))*NaN;
        total_conc_CIP = zeros(length(tas),1)*NaN;
        rej_rat_CIP = zeros(length(tas),1)*NaN;
end

%2DP
if(exist(f2DP))
	nc_2DP = netcdf.open(f2DP);

	bin_min_2DP = netcdf.getVar(nc_2DP, netcdf.inqVarID(nc_2DP, 'bin_min'));%zeros(nbins_2DP)*NaN;
	bin_max_2DP = netcdf.getVar(nc_2DP, netcdf.inqVarID(nc_2DP, 'bin_max'));%zeros(nbins_2DP)*NaN;
	bin_mid_2DP = netcdf.getVar(nc_2DP, netcdf.inqVarID(nc_2DP, 'bin_mid'));%zeros(nbins_2DP)*NaN;
	bin_dD_2DP = netcdf.getVar(nc_2DP, netcdf.inqVarID(nc_2DP, 'bin_dD'));%zeros(nbins_2DP)*NaN;
	nbins_2DP = length(bin_min_2DP);

	conc_2DP = netcdf.getVar(nc_2DP, netcdf.inqVarID(nc_2DP, 'conc_minR'));%zeros(nbins_2DS,length(tas))*NaN;
	conc_area_2DP = netcdf.getVar(nc_2DP, netcdf.inqVarID(nc_2DP, 'area'));%zeros(nareabins,nbins_2DP,length(tas))*NaN;
	total_conc_2DP = netcdf.getVar(nc_2DP, netcdf.inqVarID(nc_2DP, 'n'));%zeros(length(tas),1)*NaN;
	rej_rat_2DP = netcdf.getVar(nc_2DP, netcdf.inqVarID(nc_2DP, 'Reject_ratio'));

	netcdf.close(nc_2DP);
else
        nbins_2DP = 1;

        bin_min_2DP = zeros(nbins_2DP)*NaN;
        bin_max_2DP = zeros(nbins_2DP)*NaN;
        bin_mid_2DP = zeros(nbins_2DP)*NaN;
        bin_dD_2DP = zeros(nbins_2DP)*NaN;

        conc_2DP = zeros(nbins_2DP,length(tas))*NaN;
        conc_area_2DP = zeros(nareabins,nbins_2DP,length(tas))*NaN;
        total_conc_2DP = zeros(length(tas),1)*NaN;
        rej_rat_2DP = zeros(length(tas),1)*NaN;
end


%2DC
if(exist(f2DC))
        nc_2DC = netcdf.open(f2DC);

        bin_min_2DC = netcdf.getVar(nc_2DC, netcdf.inqVarID(nc_2DC, 'bin_min'));
        bin_max_2DC = netcdf.getVar(nc_2DC, netcdf.inqVarID(nc_2DC, 'bin_max'));
        bin_mid_2DC = netcdf.getVar(nc_2DC, netcdf.inqVarID(nc_2DC, 'bin_mid'));
        bin_dD_2DC = netcdf.getVar(nc_2DC, netcdf.inqVarID(nc_2DC, 'bin_dD'));
        nbins_2DC = length(bin_min_2DC);

        conc_2DC = netcdf.getVar(nc_2DC, netcdf.inqVarID(nc_2DC, 'conc_minR'));
        conc_area_2DC = netcdf.getVar(nc_2DC, netcdf.inqVarID(nc_2DC, 'area'));
        total_conc_2DC = netcdf.getVar(nc_2DC, netcdf.inqVarID(nc_2DC, 'n'));
        rej_rat_2DC = netcdf.getVar(nc_2DC, netcdf.inqVarID(nc_2DC, 'Reject_ratio'));

        netcdf.close(nc_2DC);
else
        nbins_2DC = 1;

        bin_min_2DC = zeros(nbins_2DC)*NaN;
        bin_max_2DC = zeros(nbins_2DC)*NaN;
        bin_mid_2DC = zeros(nbins_2DC)*NaN;
        bin_dD_2DC = zeros(nbins_2DC)*NaN;

        conc_2DC = zeros(nbins_2DC,length(tas))*NaN;
        conc_area_2DC = zeros(nareabins,nbins_2DC,length(tas))*NaN;
        total_conc_2DC = zeros(length(tas),1)*NaN;
        rej_rat_2DC = zeros(length(tas),1)*NaN;
end


mainf = netcdf.create('/kingair_data/snowie17/2DS/20170119_1/20170119a.SD.cdf', 'clobber');

%Dimensions
dimid0 = netcdf.defDim(mainf,'Time',length(timehhmmss));
dimid1 = netcdf.defDim(mainf,'areabins',nareabins);
dimid2 = netcdf.defDim(mainf,'bins_2DS',nbins_2DS);
dimid3 = netcdf.defDim(mainf,'bins_CIP',nbins_CIP);
dimid4 = netcdf.defDim(mainf,'bins_2DP',nbins_2DP);
dimid5 = netcdf.defDim(mainf,'bins_2DC',nbins_2DC);
dimid6 = netcdf.defDim(mainf,'bins_CDP',nbins_CDP);

%Global Attributes
varidG = netcdf.getConstant('GLOBAL');
[~,git_ID]=system('git rev-parse --short HEAD');
netcdf.putAtt(mainf,varidG,'creation_date',datestr(now));
netcdf.putAtt(mainf,varidG,'git_ID',git_ID);
netcdf.putAtt(mainf,varidG,'center_entire_criteria','centerin');
netcdf.putAtt(mainf,varidG,'source_files',[f2DS,', ',fCIP,', ',f2DP,', ',f2DC,', ',fCDP]);
netcdf.putAtt(mainf,varidG,'version','SNOWIE_1.0');
netcdf.putAtt(mainf,varidG,'area_desc','10 area ratio bins of width .1 (0-1.0) from non circularity (0) to perfectly circle (1.0) aspect ratio');


%Variables
varid0 = netcdf.defVar(mainf,'time','double',dimid0); 
netcdf.putAtt(mainf, varid0,'units','HHMMSS');
netcdf.putAtt(mainf, varid0,'name','Time');

%2DS
varid1 = netcdf.defVar(mainf,'bin_min_2DS','double',dimid2); 
netcdf.putAtt(mainf, varid1,'units','micron');
netcdf.putAtt(mainf, varid1,'long_name','bin minimum size');
netcdf.putAtt(mainf, varid1,'short_name','bin min');

varid2 = netcdf.defVar(mainf,'bin_max_2DS','double',dimid2); 
netcdf.putAtt(mainf, varid2,'units','micron');
netcdf.putAtt(mainf, varid2,'long_name','bin maximum size');
netcdf.putAtt(mainf, varid2,'short_name','bin max');

varid3 = netcdf.defVar(mainf,'bin_mid_2DS','double',dimid2); 
netcdf.putAtt(mainf, varid3,'units','micron');
netcdf.putAtt(mainf, varid3,'long_name','bin midpoint size');
netcdf.putAtt(mainf, varid3,'short_name','bin mid');

varid4 = netcdf.defVar(mainf,'bin_dD_2DS','double',dimid2); 
netcdf.putAtt(mainf, varid4,'units','micron');
netcdf.putAtt(mainf, varid4,'long_name','bin size');
netcdf.putAtt(mainf, varid4,'short_name','bin size');

varid5 = netcdf.defVar(mainf,'size_dist_2DS_H','double',[dimid2 dimid0]); 
netcdf.putAtt(mainf, varid5,'units','cm-3/um');
netcdf.putAtt(mainf, varid5,'long_name','Number concentration as a function of diameter, normalized by bin width');
netcdf.putAtt(mainf, varid5,'short_name','N(D)');

varid6 = netcdf.defVar(mainf,'size_dist_area_2DS_H','double',[dimid1 dimid2 dimid0]); 
netcdf.putAtt(mainf, varid6,'units','cm-3/um');
netcdf.putAtt(mainf, varid6,'long_name','Number concentration as a function of diameter and area ratio, normalized by bin width');
netcdf.putAtt(mainf, varid6,'short_name','N(D, alpha_area)');

varid7 = netcdf.defVar(mainf,'total_conc_2DS_H','double',dimid0); 
netcdf.putAtt(mainf, varid7,'units','cm-3');
netcdf.putAtt(mainf, varid7,'long_name','Number concentration');
netcdf.putAtt(mainf, varid7,'short_name','N');

varid8 = netcdf.defVar(mainf,'reject_ratio_2DS_H','double',dimid0);
netcdf.putAtt(mainf, varid8,'units','ratio');
netcdf.putAtt(mainf, varid8,'long_name','Ratio of rejected particles across all bins for specified time');
netcdf.putAtt(mainf, varid8,'short_name','alpha_rej');

varid9 = netcdf.defVar(mainf,'size_dist_2DS_V','double',[dimid2 dimid0]);
netcdf.putAtt(mainf, varid9,'units','cm-3/um');
netcdf.putAtt(mainf, varid9,'long_name','Number concentration as a function of diameter, normalized by bin width');
netcdf.putAtt(mainf, varid9,'short_name','N(D)');

varid10 = netcdf.defVar(mainf,'size_dist_area_2DS_V','double',[dimid1 dimid2 dimid0]);
netcdf.putAtt(mainf, varid10,'units','cm-3/um');
netcdf.putAtt(mainf, varid10,'long_name','Number concentration as a function of diameter and area ratio, normalized by bin width');
netcdf.putAtt(mainf, varid10,'short_name','N(D, alpha_area)');

varid11 = netcdf.defVar(mainf,'total_conc_2DS_V','double',dimid0);
netcdf.putAtt(mainf, varid11,'units','cm-3');
netcdf.putAtt(mainf, varid11,'long_name','Number concentration');
netcdf.putAtt(mainf, varid11,'short_name','N');

varid12 = netcdf.defVar(mainf,'reject_ratio_2DS_V','double',dimid0);
netcdf.putAtt(mainf, varid12,'units','ratio');
netcdf.putAtt(mainf, varid12,'long_name','Ratio of rejected particles across all bins for specified time');
netcdf.putAtt(mainf, varid12,'short_name','alpha_rej');

%CIP
varid13 = netcdf.defVar(mainf,'bin_min_CIP','double',dimid3); 
netcdf.putAtt(mainf, varid13,'units','micron');
netcdf.putAtt(mainf, varid13,'long_name','bin minimum size');
netcdf.putAtt(mainf, varid13,'short_name','bin min');

varid14 = netcdf.defVar(mainf,'bin_max_CIP','double',dimid3); 
netcdf.putAtt(mainf, varid14,'units','micron');
netcdf.putAtt(mainf, varid14,'long_name','bin maximum size');
netcdf.putAtt(mainf, varid14,'short_name','bin max');

varid15 = netcdf.defVar(mainf,'bin_mid_CIP','double',dimid3); 
netcdf.putAtt(mainf, varid15,'units','micron');
netcdf.putAtt(mainf, varid15,'long_name','bin midpoint size');
netcdf.putAtt(mainf, varid15,'short_name','bin mid');

varid16 = netcdf.defVar(mainf,'bin_dD_CIP','double',dimid3); 
netcdf.putAtt(mainf, varid16,'units','micron');
netcdf.putAtt(mainf, varid16,'long_name','bin size');
netcdf.putAtt(mainf, varid16,'short_name','bin size');

varid17 = netcdf.defVar(mainf,'size_dist_CIP','double',[dimid3 dimid0]); 
netcdf.putAtt(mainf, varid17,'units','cm-3/um');
netcdf.putAtt(mainf, varid17,'long_name','Number concentration as a function of diameter, normalized by bin width');
netcdf.putAtt(mainf, varid17,'short_name','N(D)');

varid18 = netcdf.defVar(mainf,'size_dist_area_CIP','double',[dimid1 dimid3 dimid0]); 
netcdf.putAtt(mainf, varid18,'units','cm-3/um');
netcdf.putAtt(mainf, varid18,'long_name','Number concentration as a function of diameter and area ratio, normalized by bin width');
netcdf.putAtt(mainf, varid18,'short_name','N(D, alpha_area)');

varid19 = netcdf.defVar(mainf,'total_conc_CIP','double',dimid0); 
netcdf.putAtt(mainf, varid19,'units','cm-3');
netcdf.putAtt(mainf, varid19,'long_name','Number concentration');
netcdf.putAtt(mainf, varid19,'short_name','N');

varid20 = netcdf.defVar(mainf,'reject_ratio_CIP','double',dimid0);
netcdf.putAtt(mainf, varid20,'units','ratio');
netcdf.putAtt(mainf, varid20,'long_name','Ratio of rejected particles across all bins for specified time');
netcdf.putAtt(mainf, varid20,'short_name','alpha_rej');

%2DP
varid21 = netcdf.defVar(mainf,'bin_min_2DP','double',dimid4); 
netcdf.putAtt(mainf, varid21,'units','micron');
netcdf.putAtt(mainf, varid21,'long_name','bin minimum size');
netcdf.putAtt(mainf, varid21,'short_name','bin min');

varid22 = netcdf.defVar(mainf,'bin_max_2DP','double',dimid4); 
netcdf.putAtt(mainf, varid22,'units','micron');
netcdf.putAtt(mainf, varid22,'long_name','bin maximum size');
netcdf.putAtt(mainf, varid22,'short_name','bin max');

varid23 = netcdf.defVar(mainf,'bin_mid_2DP','double',dimid4); 
netcdf.putAtt(mainf, varid23,'units','micron');
netcdf.putAtt(mainf, varid23,'long_name','bin midpoint size');
netcdf.putAtt(mainf, varid23,'short_name','bin mid');

varid24 = netcdf.defVar(mainf,'bin_dD_2DP','double',dimid4); 
netcdf.putAtt(mainf, varid24,'units','micron');
netcdf.putAtt(mainf, varid24,'long_name','bin size');
netcdf.putAtt(mainf, varid24,'short_name','bin size');

varid25 = netcdf.defVar(mainf,'size_dist_2DP','double',[dimid4 dimid0]); 
netcdf.putAtt(mainf, varid25,'units','cm-3/um');
netcdf.putAtt(mainf, varid25,'long_name','Number concentration as a function of diameter, normalized by bin width');
netcdf.putAtt(mainf, varid25,'short_name','N(D)');

varid26 = netcdf.defVar(mainf,'size_dist_area_2DP','double',[dimid1 dimid4 dimid0]); 
netcdf.putAtt(mainf, varid26,'units','cm-3/um');
netcdf.putAtt(mainf, varid26,'long_name','Number concentration as a function of diameter and area ratio, normalized by bin width');
netcdf.putAtt(mainf, varid26,'short_name','N(D, alpha_area)');

varid27 = netcdf.defVar(mainf,'total_conc_2DP','double',dimid0); 
netcdf.putAtt(mainf, varid27,'units','cm-3');
netcdf.putAtt(mainf, varid27,'long_name','Number concentration');
netcdf.putAtt(mainf, varid27,'short_name','N');

varid28 = netcdf.defVar(mainf,'reject_ratio_2DP','double',dimid0);
netcdf.putAtt(mainf, varid28,'units','ratio');
netcdf.putAtt(mainf, varid28,'long_name','Ratio of rejected particles across all bins for specified time');
netcdf.putAtt(mainf, varid28,'short_name','alpha_rej');

%2DC
varid29 = netcdf.defVar(mainf,'bin_min_2DC','double',dimid5); 
netcdf.putAtt(mainf, varid29,'units','micron');
netcdf.putAtt(mainf, varid29,'long_name','bin minimum size');
netcdf.putAtt(mainf, varid29,'short_name','bin min');

varid30 = netcdf.defVar(mainf,'bin_max_2DC','double',dimid5); 
netcdf.putAtt(mainf, varid30,'units','micron');
netcdf.putAtt(mainf, varid30,'long_name','bin maximum size');
netcdf.putAtt(mainf, varid30,'short_name','bin max');

varid31 = netcdf.defVar(mainf,'bin_mid_2DC','double',dimid5); 
netcdf.putAtt(mainf, varid31,'units','micron');
netcdf.putAtt(mainf, varid31,'long_name','bin midpoint size');
netcdf.putAtt(mainf, varid31,'short_name','bin mid');

varid32 = netcdf.defVar(mainf,'bin_dD_2DC','double',dimid5); 
netcdf.putAtt(mainf, varid32,'units','micron');
netcdf.putAtt(mainf, varid32,'long_name','bin size');
netcdf.putAtt(mainf, varid32,'short_name','bin size');

varid33 = netcdf.defVar(mainf,'size_dist_2DC','double',[dimid5 dimid0]); 
netcdf.putAtt(mainf, varid33,'units','cm-3/um');
netcdf.putAtt(mainf, varid33,'long_name','Number concentration as a function of diameter, normalized by bin width');
netcdf.putAtt(mainf, varid33,'short_name','N(D)');

varid34 = netcdf.defVar(mainf,'size_dist_area_2DC','double',[dimid1 dimid5 dimid0]); 
netcdf.putAtt(mainf, varid34,'units','cm-3/um');
netcdf.putAtt(mainf, varid34,'long_name','Number concentration as a function of diameter and area ratio, normalized by bin width');
netcdf.putAtt(mainf, varid34,'short_name','N(D, alpha_area)');

varid35 = netcdf.defVar(mainf,'total_conc_2DC','double',dimid0); 
netcdf.putAtt(mainf, varid35,'units','cm-3');
netcdf.putAtt(mainf, varid35,'long_name','Number concentration');
netcdf.putAtt(mainf, varid35,'short_name','N');

varid36 = netcdf.defVar(mainf,'reject_ratio_2DC','double',dimid0);
netcdf.putAtt(mainf, varid36,'units','ratio');
netcdf.putAtt(mainf, varid36,'long_name','Ratio of rejected particles across all bins for specified time');
netcdf.putAtt(mainf, varid36,'short_name','alpha_rej');

%CDP
varid37 = netcdf.defVar(mainf,'bin_min_CDP','double',dimid6); 
netcdf.putAtt(mainf, varid37,'units','micron');
netcdf.putAtt(mainf, varid37,'long_name','bin minimum size');
netcdf.putAtt(mainf, varid37,'short_name','bin min');

varid38 = netcdf.defVar(mainf,'bin_max_CDP','double',dimid6); 
netcdf.putAtt(mainf, varid38,'units','micron');
netcdf.putAtt(mainf, varid38,'long_name','bin maximum size');
netcdf.putAtt(mainf, varid38,'short_name','bin max');

varid39 = netcdf.defVar(mainf,'bin_mid_CDP','double',dimid6); 
netcdf.putAtt(mainf, varid39,'units','micron');
netcdf.putAtt(mainf, varid39,'long_name','bin midpoint size');
netcdf.putAtt(mainf, varid39,'short_name','bin mid');

varid40 = netcdf.defVar(mainf,'bin_dD_CDP','double',dimid6); 
netcdf.putAtt(mainf, varid40,'units','micron');
netcdf.putAtt(mainf, varid40,'long_name','bin size');
netcdf.putAtt(mainf, varid40,'short_name','bin size');

varid41 = netcdf.defVar(mainf,'size_dist_CDP','double',[dimid6 dimid0]); 
netcdf.putAtt(mainf, varid41,'units','cm-3/um');
netcdf.putAtt(mainf, varid41,'long_name','Number concentration as a function of diameter, normalized by bin width');
netcdf.putAtt(mainf, varid41,'short_name','N(D)');

varid42 = netcdf.defVar(mainf,'total_conc_CDP','double',dimid0); 
netcdf.putAtt(mainf, varid42,'units','cm-3');
netcdf.putAtt(mainf, varid42,'long_name','Number concentration');
netcdf.putAtt(mainf, varid42,'short_name','N');

netcdf.endDef(mainf)

% Output Variables
%2DS
netcdf.putVar ( mainf, varid0, timehhmmss );
netcdf.putVar ( mainf, varid1, bin_min_2DS.*1.0e3 );%mm*1000um/mm
netcdf.putVar ( mainf, varid2, bin_max_2DS.*1.0e3 );
netcdf.putVar ( mainf, varid3, bin_mid_2DS.*1.0e3 );
netcdf.putVar ( mainf, varid4, bin_dD_2DS.*1.0e3 );
netcdf.putVar ( mainf, varid5, double(conc_2DS_H.*1.0e-4) );%cm-4*(1cm/10000um)
netcdf.putVar ( mainf, varid6, double(conc_area_2DS_H.*1.0e-4) );
netcdf.putVar ( mainf, varid7, double(total_conc_2DS_H.*1.0e-4) );
netcdf.putVar ( mainf, varid8, double(rej_rat_2DS_H) );

netcdf.putVar ( mainf, varid9, double(conc_2DS_V.*1.0e-4) );%cm-4*(1cm/10000um)
netcdf.putVar ( mainf, varid10, double(conc_area_2DS_V.*1.0e-4) );
netcdf.putVar ( mainf, varid11, double(total_conc_2DS_V.*1.0e-4) );
netcdf.putVar ( mainf, varid12, double(rej_rat_2DS_V) );

%CIP
netcdf.putVar ( mainf, varid13, bin_min_CIP.*1.0e3 );
netcdf.putVar ( mainf, varid14, bin_max_CIP.*1.0e3 );
netcdf.putVar ( mainf, varid15, bin_mid_CIP.*1.0e3 );
netcdf.putVar ( mainf, varid16, bin_dD_CIP.*1.0e3 );
netcdf.putVar ( mainf, varid17, double(conc_CIP.*1.0e-4) );
netcdf.putVar ( mainf, varid18, double(conc_area_CIP.*1.0e-4) );
netcdf.putVar ( mainf, varid19, double(total_conc_CIP.*1.0e-4) );
netcdf.putVar ( mainf, varid20, double(rej_rat_CIP) );

%2DP
netcdf.putVar ( mainf, varid21, bin_min_2DP.*1.0e3 );
netcdf.putVar ( mainf, varid22, bin_max_2DP.*1.0e3 );
netcdf.putVar ( mainf, varid23, bin_mid_2DP.*1.0e3 );
netcdf.putVar ( mainf, varid24, bin_dD_2DP.*1.0e3 );
netcdf.putVar ( mainf, varid25, double(conc_2DP.*1.0e-4) );
netcdf.putVar ( mainf, varid26, double(conc_area_2DP.*1.0e-4) );
netcdf.putVar ( mainf, varid27, double(total_conc_2DP.*1.0e-4) );
netcdf.putVar ( mainf, varid28, double(rej_rat_2DP) );

%2DC
netcdf.putVar ( mainf, varid29, bin_min_2DC.*1.0e3 );
netcdf.putVar ( mainf, varid30, bin_max_2DC.*1.0e3 );
netcdf.putVar ( mainf, varid31, bin_mid_2DC.*1.0e3 );
netcdf.putVar ( mainf, varid32, bin_dD_2DC.*1.0e3 );
netcdf.putVar ( mainf, varid33, double(conc_2DC.*1.0e-4) );
netcdf.putVar ( mainf, varid34, double(conc_area_2DC.*1.0e-4) );
netcdf.putVar ( mainf, varid35, double(total_conc_2DC.*1.0e-4) );
netcdf.putVar ( mainf, varid36, double(rej_rat_2DS) );

%CDP
netcdf.putVar ( mainf, varid37, bin_min_CDP );
netcdf.putVar ( mainf, varid38, bin_max_CDP );
netcdf.putVar ( mainf, varid39, bin_mid_CDP );
netcdf.putVar ( mainf, varid40, bin_dD_CDP );
netcdf.putVar ( mainf, varid41, double(conc_CDP) );
netcdf.putVar ( mainf, varid42, double(total_conc_CDP) );

netcdf.close(mainf);

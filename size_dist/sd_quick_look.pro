pro SD_quick_look, inf, starttime, endtime
  ;2DS size dist
  ncid = ncdf_open(inf)
  varid = ncdf_varid(ncid, 'bin_mid_2DS')
  ncdf_varget, ncid, varid, bin_mid_2DS
  varid = ncdf_varid(ncid, 'bin_dD_2DS')
  ncdf_varget, ncid, varid, bin_dD_2DS
  varid = ncdf_varid(ncid, 'time')
  ncdf_varget, ncid, varid, hhmmss
  varid = ncdf_varid(ncid, 'size_dist_2DS_H')
  ncdf_varget, ncid, varid, conc_2DS
  
  ;starttime = 155000
  ;endtime = 155100
  ind = where((hhmmss GT starttime) AND (hhmmss LT endtime))
  sd_2DS = mean(conc_2DS[*,ind],2,/NAN) ;cm-4 averaged over time from conc_minR
  p1 = plot(bin_mid_2DS, sd_2DS, 'k*-', /xlog, /ylog)

  varid = ncdf_varid(ncid, 'bin_mid_CIP')
  ncdf_varget, ncid, varid, bin_mid_CIP
  varid = ncdf_varid(ncid, 'bin_dD_CIP')
  ncdf_varget, ncid, varid, bin_dD_CIP
  varid = ncdf_varid(ncid, 'size_dist_CIP')
  ncdf_varget, ncid, varid, conc_CIP

  sd_CIP = mean(conc_CIP[*,ind],2,/NAN) ;cm-4 averaged over time from conc_minR
  ;stop
  p2 = plot(bin_mid_CIP, sd_CIP, 'b*-', /overplot)
  
  varid = ncdf_varid(ncid, 'bin_mid_2DP')
  ncdf_varget, ncid, varid, bin_mid_2DP
  varid = ncdf_varid(ncid, 'bin_dD_2DP')
  ncdf_varget, ncid, varid, bin_dD_2DP
  varid = ncdf_varid(ncid, 'size_dist_2DP')
  ncdf_varget, ncid, varid, conc_2DP

  sd_2DP = mean(conc_2DP[*,ind],2,/NAN) ;cm-4 averaged over time from conc_minR
  p3 = plot(bin_mid_2DP, sd_2DP, 'r*-', /overplot)
  
  varid = ncdf_varid(ncid, 'bin_mid_CDP')
  ncdf_varget, ncid, varid, bin_mid_CDP
  varid = ncdf_varid(ncid, 'bin_dD_CDP')
  ncdf_varget, ncid, varid, bin_dD_CDP
  varid = ncdf_varid(ncid, 'size_dist_CDP')
  ncdf_varget, ncid, varid, conc_CDP

  sd_CDP = mean(conc_CDP[*,ind],2,/NAN) ;cm-4 averaged over time from conc_minR
  p4 = plot(bin_mid_CDP, sd_CDP, 'g*-', /overplot)
  
  ;stop
end
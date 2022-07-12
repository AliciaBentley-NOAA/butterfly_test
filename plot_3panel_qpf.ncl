; ===========================================
; Plots accumulated precipitation
; Created by: Alicia M. Bentley
; ===========================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
; ===========================================

begin

print(" ")
print("**************")
print(" START SCRIPT ")
print("**************")

;*******************************************************
; Define what variables, domains, and directories
;*******************************************************

varname = "gfs_qpf"
project = "butterfly"  ; event name

folder = (/"global","northamer"/)       ; domain(s) to plot
enddomain = dimsizes(folder)
do x = 0,enddomain-1       ; loop through all the domains you selected (only 1 domain if 1 domain selected)
domain = folder(x)

testlist = (/"3vs4"/)       ; test(s) to plot
endtest = dimsizes(testlist)
do t = 0,endtest-1       ; loop through all the tests you selected (only 1 test if 1 test selected)
test = testlist(t)

img_loc = "/gpfs/dell2/emc/verification/save/Alicia.Bentley/"+project+"/images"   ; Define directory where images will ultimately be located (and create it)
system("mkdir "+img_loc)
system("mkdir "+img_loc+"/"+test)
dir_out = img_loc+"/"+test+"/"

print(" ")
print("Plotting '"+varname+"' for '"+test+"' over '"+domain+"'")  ; Print what you are plotting
print("Images finally located: "+dir_out)


;*******************************************************
; Define what dates to plot
;*******************************************************

byyyy = 2021            ; Define first date to plot (yyyy mm dd hh)
bmm = 12
bdd = 27
bhh = 00

eyyyy = 2022    ; Define last date to plot (yyyy mm dd hh)
emm = 1
edd = 12
ehh = 00

timeUnits = "hours since 1800-01-01 00:00:00"
bdate = cd_inv_calendar(byyyy,bmm,bdd,bhh,00,00,timeUnits,0)
edate = cd_inv_calendar(eyyyy,emm,edd,ehh,00,00,timeUnits,0)

print(" ")
print("bdate: "+cd_calendar(bdate,-3))
print("edate: "+cd_calendar(edate,-3))

counter = 0

do date = bdate,edate,24       ; Create images from start date to end date (with 24 h increments)

; ******************************************************
; Load files
; ******************************************************
    print(" ")
    print("Date:  "+cd_calendar(date,-3)+" | Creating image")     ; Print date currently being plotted
        modelstrings=tostring(cd_calendar(date,-3))        
        yyyy = str_get_cols(modelstrings,0,3)
        mm = str_get_cols(modelstrings,4,5)
        dd = str_get_cols(modelstrings,6,7)
        hh = str_get_cols(modelstrings,8,9)

        fhr = date-bdate
        imgnumber = counter+(fhr/24.)

                 if (fhr.lt.10) then
                      filefhr := "00"+fhr
                 else if ((fhr.lt.100).and.(fhr.gt.10)) then
                      filefhr := "0"+fhr
                 else if (fhr.gt.100) then
                      filefhr := fhr
                 end if
                 end if
                 end if

print("filefhr: "+filefhr)
print("yyyymmddhh: "+yyyy+mm+dd+hh)
name=varname+"_"+test+"_"+domain+"_"+imgnumber
print("name: "+name)

if test .eq. "1vs2" then
infile1="/gpfs/dell3/ptmp/Kate.Friedman/comrot/v162_bf1/gfs.20211227/00/atmos/gfs.t"+hh+"z.pgrb2.0p25.f"+filefhr
print("infile1: "+infile1)
infile2="/gpfs/dell3/ptmp/Kate.Friedman/comrot/v162_bf2/gfs.20211227/00/atmos/gfs.t"+hh+"z.pgrb2.0p25.f"+filefhr
print("infile2: "+infile2)
testnum1 = 1
testnum2 = 2
end if

if test .eq. "1vs3" then
infile1="/gpfs/dell3/ptmp/Kate.Friedman/comrot/v162_bf1/gfs.20211227/00/atmos/gfs.t"+hh+"z.pgrb2.0p25.f"+filefhr
print("infile1: "+infile1)
infile2="/gpfs/dell3/ptmp/Kate.Friedman/comrot/v162_bf3/gfs.20211227/00/atmos/gfs.t"+hh+"z.pgrb2.0p25.f"+filefhr
print("infile2: "+infile2)
testnum1 = 1
testnum2 = 3
end if

if test .eq. "1vs4" then
infile1="/gpfs/dell3/ptmp/Kate.Friedman/comrot/v162_bf1/gfs.20211227/00/atmos/gfs.t"+hh+"z.pgrb2.0p25.f"+filefhr
print("infile1: "+infile1)
infile2="/gpfs/dell3/ptmp/Kate.Friedman/comrot/v162_bf4/gfs.20211227/00/atmos/gfs.t"+hh+"z.pgrb2.0p25.f"+filefhr
print("infile2: "+infile2)
testnum1 = 1
testnum2 = 4
end if

if test .eq. "3vs4" then
infile1="/gpfs/dell3/ptmp/Kate.Friedman/comrot/v162_bf3/gfs.20211227/00/atmos/gfs.t"+hh+"z.pgrb2.0p25.f"+filefhr
print("infile1: "+infile1)
infile2="/gpfs/dell3/ptmp/Kate.Friedman/comrot/v162_bf4/gfs.20211227/00/atmos/gfs.t"+hh+"z.pgrb2.0p25.f"+filefhr
print("infile2: "+infile2)
testnum1 = 3
testnum2 = 4
end if

   prod_gfs = addfile(infile1+".grb2","r")
   test_gfs = addfile(infile2+".grb2","r")

   if (fhr .eq. 0) then
      precipprod=prod_gfs->HGT_P0_L100_GLL0({50000},:,:)
      preciptest=test_gfs->HGT_P0_L100_GLL0({50000},:,:)
      precipprod=precipprod*0.0
      preciptest=preciptest*0.0
      precipplotprod=precipprod
      precipplottest=preciptest
   else
     if (fhr .eq. 6) then
        var = "APCP_P8_L1_GLL0_acc"
     else if (fhr .gt. 6) then
        var = "APCP_P8_L1_GLL0_acc"+fhr+"h"
     end if
     end if
     print("var: "+var)

      precipprod=prod_gfs->$var$
      preciptest=test_gfs->$var$
      precipprod=precipprod*.03937
      preciptest=preciptest*.03937
      precipplotprod=precipprod
      precipplottest=preciptest
    end if

  dif = precipplottest
  dif = precipplottest-precipplotprod
  printMinMax(dif,True)

if domain .eq. "global" then
do d = 0,5,1
  precipplotprod = smth9(precipplotprod, 0.50,  0.25, True)
  precipplottest = smth9(precipplottest, 0.50,  0.25, True)
  dif = smth9(dif, 0.50,  0.25, True)
end do
end if

;==============================================
; Create Shaded Map
;==============================================

wks_type = "png"

wks_type@wkWidth = 1600
wks_type@wkHeight = 1600

wks = gsn_open_wks(wks_type,dir_out+name)
gsn_define_colormap(wks,"temp")

plot=new(3,"graphic")
;**********************************************

res = True

res@gsnFrame = False                                             ;DO NOT PLOT FIRST MAP
res@gsnDraw = False

res@mpDataBaseVersion = "MediumRes"                              ; Country Outlines
res@mpDataSetName = "Earth..4"
res@mpOutlineBoundarySets = "National"

res@cnFillOn = True                                              ; Turn on color fill
res@cnFillMode = "AreaFill"
res@cnRasterSmoothingOn = True
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLinesOn = False                               ; Relative Vorticity Shading Information
res@cnFillColors=(/"transparent","lawngreen","green3","green4","blue1","dodgerblue1","cyan1","mediumpurple3","darkorchid3","darkorchid4","red4","red3","darkorange2","darksalmon","yellow1","sienna4","magenta2","lightpink2","mistyrose","oldlace","black"/)
res@cnLevels=(/.01,0.10,0.25,0.50,0.75,1.00,1.5,2.00,3.0,4.00,5.00,6.0,8.00,10.0,15.0,20.0/)

;**********************************************

res@lbAutoManage = False                                                        ; Color bar information
res@pmLabelBarOrthogonalPosF = -.06
res@pmLabelBarHeightF = 0.08
res@pmLabelBarWidthF = 0.60
res@lbLabelAutoStride = False
res@lbLabelFontHeightF = 0.0124
res@lbBoxLinesOn  = True
res@lbTopMarginF = .3

;**********************************************

res@tiMainString = " "                                                          ; Image labels
res@tiMainJust = "CenterCenter"
res@tiMainPosition = "Center"
res@tiMainOffsetYF = .02
res@tiXAxisFontHeightF = .015

res@gsnLeftStringOrthogonalPosF = .012
res@gsnLeftStringFontHeightF = .008
res@gsnRightString = " "
res@gsnRightStringOrthogonalPosF = .0075
res@gsnRightStringFontHeightF = .012

; *********************************************

res@mpGeophysicalLineThicknessF = 5.0                           ; Map details
res@mpNationalLineThicknessF = 5.0
res@mpUSStateLineThicknessF = 2.0
res@mpOutlineSpecifiers = (/"United States"/)+" : States"

res@mpGeophysicalLineColor = "grey29"
res@mpNationalLineColor = "grey29"
res@mpUSStateLineColor = "grey29"

; *********************************************

res@mpGridAndLimbOn = True                                                      ; Grid lines and tick mark information
res@mpGridLineDashPattern = 5
res@mpGridLatSpacingF = 20.
res@mpGridLonSpacingF = 20.
res@mpGridLineThicknessF = 3
res@mpGridLineColor = "grey12"

; *************************************************************

cnres = True                                            ; Geopotential height information

cnres@gsnFrame = False
cnres@gsnDraw = False

cnres@gsnLeftString = " "
cnres@gsnRightString = " "

cnres@cnInfoLabelOn = False
cnres@cnFillOn = False
cnres@cnLinesOn = True
cnres@cnLabelMasking = True
cnres@cnLineThicknessF = 4
cnres@cnLevelSelectionMode = "ManualLevels"
cnres@cnLevelSpacingF = 6
cnres@cnMinLevelValF = 450
cnres@cnMaxLevelValF = 606
cnres@cnLineLabelAngleF = 0.0
cnres@cnLineLabelInterval = 2
cnres@cnLineLabelDensityF = .90
;cnres@cnSmoothingOn = True
;cnres@cnSmoothingDistanceF = 0.009
cnres@cnLineLabelBackgroundColor = -1
cnres@cnLineLabelFontHeightF = 0.008
cnres@gsnAddCyclic = True

; *************************************************************

if domain .eq. "northamer" then                                     ; Define domains
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 31
res@mpLambertParallel1F = 11
res@mpLambertMeridianF = -100
res@mpLimitMode = "LatLon"
res@mpMinLatF = 8
res@mpMaxLatF = 69
res@mpMinLonF = -151
res@mpMaxLonF = -49
res@tmXBValues := ispan(-180,179,40)
res@tmYLValues := ispan(0,80,20)
res@tmYRValues := ispan(0,80,20)
end if

if domain .eq. "global" then
res@mpGeophysicalLineThicknessF = 4.0
res@mpNationalLineThicknessF = 4.0
res@mpUSStateLineThicknessF = 2.0
res@mpGridLineDashPattern = 5
res@mpGridLatSpacingF = 30.
res@mpGridLonSpacingF = 30.
res@mpGridLineThicknessF = 1
res@pmLabelBarOrthogonalPosF = .03
cnres@cnLineThicknessF = 1
end if

; *************************************************************
res@mpFillOn = True
res@mpOutlineOn = True
res@mpFillDrawOrder = "PreDraw"
res@cnFillDrawOrder = "PreDraw"
cnres@cnLineDrawOrder ="Draw"
res@mpOutlineDrawOrder = "Draw"
res@mpGridAndLimbDrawOrder = "PostDraw"

res@gsnLeftString = "GFS | Test: "+testnum1+" | Init.: "+cd_string(bdate,"")+" | Fhr: "+fhr+" | Valid: "+cd_string(date,"")+" | Accum. Precipitation (in.)"
plot(0) = gsn_csm_contour_map(wks, precipplotprod, res)          ; Plot filled contour map
;contours = gsn_csm_contour(wks, geo1, cnres)
;overlay(plot(0),contours)

res@gsnLeftString = "GFS | Test: "+testnum2+" | Init.: "+cd_string(bdate,"")+" | Fhr: "+fhr+" | Valid: "+cd_string(date,"")+" | Accum. Precipitation (in.)"
plot(1) = gsn_csm_contour_map(wks, precipplottest, res)          ; Plot filled contour map
;contours1 = gsn_csm_contour(wks, geo2, cnres)
;overlay(plot(1),contours1)

;********************************************

  resdif=True
  resdif=res
  resdif@cnFillPalette=("BlueWhiteOrangeRed")
  delete(resdif@cnFillColors)
  delete(resdif@cnLevels)
  resdif@cnLevels:=(/-5,-4,-3,-2,-1.5,-1,-.5,-.25,0,.25,.5,1,1.5,2,3,4,5/)
  resdif@gsnLeftString = "GFS | Test: "+testnum2+"-"+testnum1+" | Init.: "+cd_string(bdate,"")+" | Fhr: "+fhr+" | Valid: "+cd_string(date,"")+" | Accum. Precipitation (in.)"
  plot(2) = gsn_csm_contour_map(wks,dif,resdif)       ; create a default plot

;********************************************

  resP=True
  resP@gsnMaximize=True
  resP@txFontHeightF=.012
  resP@gsnPanelLabelBar=False
  resP@gsnFrame=False
  gsn_panel(wks,plot,(/2,2/),resP)

;draw(plot)      ; Draw final image
frame(wks)

;********************************************

system("convert "+dir_out+name+".png -trim +repage "+dir_out+name+".gif")
system("'rm' "+dir_out+name+".png")

end do     ; end date loop
print(" ")
end do     ; end test loop
end do     ; end domain loop

print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end

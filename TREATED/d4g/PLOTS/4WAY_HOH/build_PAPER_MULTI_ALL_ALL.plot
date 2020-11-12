reset
set term post enh color 12
set output "PAPER_MULTI_All_Site_ALL_ALL.ps"
## General Labels 
set label 100 "Distance to Backbone H" at screen 0.5,0.03 center front
set label 101 "Distance to NAc H" at screen 0.10,0.5 center rotate front
set label 203 "THR 3" at screen 0.20,0.96 center front
set label 204 "THR 4" at screen 0.40,0.96 center front
set label 205 "THR 5" at screen 0.60,0.96 center front
set label 206 "THR 6" at screen 0.80,0.96 center front
set label 10 "Backbone Oxygen" at screen 0.08,0.25 center rotate front
set label 20 "Glycosidic Oxygen" at screen 0.08,0.75 center rotate front
set multiplot
load "PAPER_MULTI_All_site-4_O.plot"
load "PAPER_MULTI_All_site-5_O.plot"
load "PAPER_MULTI_All_site-6_O.plot"
load "PAPER_MULTI_All_site-7_O.plot"
load "PAPER_MULTI_All_site-4_OG1.plot"
load "PAPER_MULTI_All_site-5_OG1.plot"
load "PAPER_MULTI_All_site-6_OG1.plot"
load "PAPER_MULTI_All_site-7_OG1.plot"
unset multiplot
##
## Use gimp to crop and convert to other formats
##

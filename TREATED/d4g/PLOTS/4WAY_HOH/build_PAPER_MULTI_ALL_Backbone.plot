reset
set term post enh color 12
set output "PAPER_MULTI_All_Site_ALL_Backbone.ps"
set label 11 "Backbone O to NAc H Distance" at screen 0.08,0.33 center rotate front
set label 12 "Backbone O to Backbone H Distance" at screen 0.5,0.08 center front
set multiplot
load "PAPER_MULTI_All_site-4_O.plot"
load "PAPER_MULTI_All_site-5_O.plot"
load "PAPER_MULTI_All_site-6_O.plot"
load "PAPER_MULTI_All_site-7_O.plot"
unset multiplot
##
## Use gimp to crop and convert to other formats
##

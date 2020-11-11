reset
set term post enh color 12
set output "PAPER_MULTI_All_Site_ALL_Glycosidic.ps"
set label 11 "Glycosidic O to NAc H Distance" at screen 0.08,0.33 center rotate front
set label 12 "Glycosidic O to Backbone H Distance" at screen 0.5,0.08 center front
set multiplot
load "PAPER_MULTI_All_site-4_OG1.plot"
load "PAPER_MULTI_All_site-5_OG1.plot"
load "PAPER_MULTI_All_site-6_OG1.plot"
load "PAPER_MULTI_All_site-7_OG1.plot"
unset multiplot
##
## Use gimp to crop and convert to other formats
##

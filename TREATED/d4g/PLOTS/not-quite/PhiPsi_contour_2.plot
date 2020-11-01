set parametric
set contour base
set view 0,0,1
unset surface
set dgrid3d

set cntrparam cubicspline

### each one needs its own set of labels, I think...
##
#set cntrparam levels discrete 0.12,0.1,0.08,0.07,0.06,0.05,0.045,0.04,0.035,0.03,0.02,0.01
set cntrparam levels auto 20

#set term post enh color solid 16
#set output "P_find_lines_2.ps"

#splot "../PhiPsi_Bins/P_CONT_2" using 1:2:4 with lines
splot "P_CONT_2_minus_large" using 1:2:4 with lines

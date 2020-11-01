set parametric
set contour base
set view 0,0,1
unset surface
set dgrid3d

unset key
set cntrparam cubicspline
#set cntrparam linear
#set cntrlabel font ".1"
#set cntrlabel onecolor
#set cntrparam bspline
#set cntrparam order 8

### each one needs its own set of labels, I think...
##
## these aren't so good
## set cntrparam levels discrete 0.14,0.12,0.1,0.08,0.075,0.07,0.06,0.065,0.05,0.045,0.04
##
set cntrparam levels discrete 0.14,0.12,0.09,0.075,0.07,0.065,0.045,0.04

#set term post enh color solid 16
#set output "P_find_lines_1.ps"

splot "../PhiPsi_Bins/P_CONT_1" using 1:2:4 with lines

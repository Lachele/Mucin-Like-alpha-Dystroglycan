reset
se xla "N-N Distance"
se yla "Counts"

se term post enh color solid 16
set output "N-N_distance_fig.ps"

Ng=317740
Nm=355643
Np=520408

plot "d4g/ANALYSIS/DIST/N-N_ALl_binning_bins.txt" using 1:($2/Ng) with imp lw 3 ti "GalNAc", "d4m/ANALYSIS/DIST/N-N_ALl_binning_bins.txt"using 1:($2/Nm)  with imp lw 2  ti "Man", "protein/ANALYSIS/DIST/N-N_ALl_binning_bins.txt" using 1:($2/Np) with imp lw 1  ti "Protein"

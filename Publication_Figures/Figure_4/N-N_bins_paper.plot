set term post enh solid color "Helvetica" 20
set output "N-N_bins_paper.ps"
set key left top Left reverse
set xla "N(THR3) to N(LYS7) Distance, Angstroms"
set yla "Fraction of Simulated Population"
set ytics 0.01
# Numbers of total data points each set
Ng=317740
Nm=355643
Np=520408
plot "d4g_N-N_ALl_binning_bins.txt" using 1:($2/Ng)with imp lw 3.5 lt rgb "red" ti "N-acetyl Galactosylated Peptide", "d4m_N-N_ALl_binning_bins.txt" using 1:($2/Nm)with imp lw 3.25 lt rgb "green" ti "Mannosylated Peptide", "protein_N-N_ALl_binning_bins.txt" using 1:($2/Np)with imp lw 2 lt rgb "blue" ti "Unglycosylated Peptide"


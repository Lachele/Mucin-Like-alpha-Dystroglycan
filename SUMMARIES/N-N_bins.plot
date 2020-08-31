set term post enh solid color "Helvetica" 26
set output "N-N_bins.ps"
set key left top Left reverse
set xla "N(THR3) to N(LYS7) Distance, Angstroms"
set yla "Fraction of Simulated Population"
plot "d4g/ANALYSIS/MANUAL/DIST/N-N_bins.txt" using 1:($2/317018)with imp lw 3.5 ti "N-acetyl Galactosylated Peptide", "d4m/ANALYSIS/MANUAL/DIST/N-N_bins.txt" using 1:($2/344988)with imp lw 2.75 ti "Mannosylated Peptide", "protein/ANALYSIS/MANUAL/DIST/N-N_bins.txt" using 1:($2/355461)with imp lw 2 ti "Unglycosylated Peptide"


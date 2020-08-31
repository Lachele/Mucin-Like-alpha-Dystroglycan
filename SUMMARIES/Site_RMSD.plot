set term post enh 16 color solid
set output "Site_RMSD.ps"
se title "Per-site Average RMSDs to NMR Structs for Glycan Ring After Aligning THR CA,C,O,N,H"
se xla "Site"
se yla "RMSD"
plot "Site_glycan_info_GalNAc.txt" using ($1-0.25):2:3 with yerr lw 3 ps 3 ti "GalNAc", "Site_glycan_info_Man.txt" using ($1-0.25):2:3 with yerr lw 3 ps 3 ti "Man"

count_Peaks
---------
Scripts to search overlapping between two bed files

Features
---------
The scripts to search overlapping between two bed files.  
It is designed to find CLIP-peaks overlapping with genes/exons/regions. 

Author
---------
Kei IIDA, iida.kei.3r@kyoto-u.ac.jp

Requirement
---------
 * Perl is required.  
  (The current version is tested on 64 bit Linux.)
 * samtools is required.
 
 DEMO
---------
This demo is for search SFPQ peaks overlapping with intronic regions.  
Genes on chr17, chr18, and chr19 in the genome annotaion GRCm38.p4 from Refseq, and SFPQ-binding peaks on the chromosomes are used.  
A directory ./test_files/bam_files_SE/ contains two files for SFPQ-binding peaks.
One is High-S peaks which mean "high-strigent binding of SFPQ",  
and the other is Low-S peaks meaning "low-strigent binding of SFPQ".  
See detail for the peak definition; [Takeuch *et al.* 2018. *Cell Rep.*](https://doi.org/10.1016/j.celrep.2018.03.141 "DOI").  
Raw files are found at NCBI GEO site with an accession ID: [GSE96080](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?GSE96080 "NCBI GEO").

```
## 1.Prepare a bed file for intronic regions.
./scripts/print_Introns.pl test_files/refseq_mm10_GRCm38.p4.representative.chr17_chr19.bed > refseq_mm10_GRCm38.p4.representative.chr17_chr19.introns.bed


## 2. Serarch and count CLIP-peaks on the intronic regions.
# count_Peaks.pl [bed_file(1)] [bed_file(2)] [Threshold_for_overlapping(0-1)]
# ID in bed_file(2) must be unique.
# Threshold: 0 means overlapping with at least 1 nucleotide is treated as overlapping.
# Threshold: 1.0 means one region must be completely included by the oter for the overlapping.
# Only Start and End positions were used for this calculation (i.e. exon structure is ignored.)
scripts/count_Peaks.pl refseq_mm10_GRCm38.p4.representative.chr17_chr19.introns.bed test_files/N2A_Peaks_HighS.chr17_chr19.bed 0 > refseq_mm10_GRCm38.p4.representative.chr17_chr19.introns.vs_N2A_Peaks_HighS.txt
scripts/count_Peaks.pl refseq_mm10_GRCm38.p4.representative.chr17_chr19.introns.bed test_files/N2A_Peaks_LowS.chr17_chr19.bed 0 > refseq_mm10_GRCm38.p4.representative.chr17_chr19.introns.vs_N2A_Peaks_LowS.txt
```

Output
---------

| #ID1 | IDs2 | Num_of_Overlapped_ID2 |
| --- | --- | --- |
| NM_001282093.I1 | - | 0 |
| NM_001282093.I2 |	- |	0 |
| NM_001282093.I3 |	P2_FC1_IP1_chr18_P_00060,P2_FC1_IP1_chr18_P_00064 | 2 |
| NM_001282093.I4 |	- |	0|

* Column 1; ID in bed files(1)
* Column 2; ID in bed files(2) overlapping with ID(1)
* Column 3; Counts for Overlapped Peaks.

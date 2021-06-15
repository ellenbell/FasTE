# Quick_TE
This repository is designed to be used as a quick use guide to two packages; the Extensive de novo TE Annotator (EDTA) and DeepTE which may be used in tandem for *de novo* transposable element (TE) library generation. It then provides a walk-through of TE screening with RepeatMasker


## Dependencies

[Extensive de novo TE Annotator (EDTA)](https://github.com/oushujun/EDTA) <br />
[DeepTE](https://github.com/LiLabAtVT/DeepTE) <br />
[RepeatMasker](https://www.repeatmasker.org) <br />
[RM_TRIPS](https://github.com/clbutler/RM_TRIPS) <br />

## Recommended installation for [EDTA](https://github.com/oushujun/EDTA) <br />

Download the latest EDTA <br />
```
git clone https://github.com/oushujun/EDTA.git
```
Find the yml file in the folder and run <br />
```
conda env create -f EDTA.yml
```
## Recommended installation for [DeepTE](https://github.com/LiLabAtVT/DeepTE) <br />

Download the latest DeepTE scripts <br />
```
Install conda: https://www.anaconda.com/products/individual
conda create -n py36 python=3.6
conda activate py36
conda install tensorflow-gpu=1.14.0
conda install biopython
conda install keras=2.2.4
conda install numpy=1.16.0
```
If this installation has been completed the following commands will apply <br />

## Step 1: TE Annotation with EDTA:
```
conda activate EDTA 
perl [path to EDTA script]/EDTA.pl --genome [path to fasta file genome assembly] --species others --sensitive 1 --threads 42 
exit
```
 --genome [file] path to genome FASTA file 
 --species [rice|Maize|others] in this instance we were working on a teleost fish species so used "others"
 --sensitive [0|1] Use RepeatModeler to identify remaining TEs (1) or not (0, default), we ran it with RepeatModeler.
 --threads Number of threads to run this script (default 4), we ran it with 42. 
 Other options are available, see https://github.com/oushujun/EDTA
 
This was tested with Linux Ubuntu (v18.04.5), 32 cores, 64 threads, 128GB RAM on a genome (size c.700MB). 
On this system with this genome EDTA ran in c.60 hours. 
 






# Quick_TE
This repository is designed to be used as a quick use guide to two packages; the Extensive de novo TE Annotator (EDTA) and DeepTE which may be used in tandem for *de novo* transposable element (TE) library generation. It then provides a walk-through of TE screening with RepeatMasker

<img width="1076" alt="Screenshot 2021-06-15 at 16 56 24" src="https://user-images.githubusercontent.com/46861035/122085468-a7765400-cdfa-11eb-85cb-ae0165dbe3ce.png">

## Dependencies

[Extensive de novo TE Annotator (EDTA)](https://github.com/oushujun/EDTA) <br />
[DeepTE](https://github.com/LiLabAtVT/DeepTE) <br />
[RepeatMasker](https://www.repeatmasker.org) <br />
[RM_TRIPS](https://github.com/clbutler/RM_TRIPS) <br />

### Recommended installation for [EDTA](https://github.com/oushujun/EDTA) <br />

Download the latest EDTA <br />
```
git clone https://github.com/oushujun/EDTA.git
```
Find the yml file in the folder and run <br />
```
conda env create -f EDTA.yml
```
### Recommended installation for [DeepTE](https://github.com/LiLabAtVT/DeepTE) <br />

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

## Part 1: TE Library Generation 

### TE Annotation with EDTA
```
conda activate EDTA 
perl [path to EDTA script]/EDTA.pl --genome [path to fasta file genome assembly] --species others --sensitive 1 --threads 42 
exit
```
 --genome [file] path to genome FASTA file <br />
 --species [rice|Maize|others] in this instance we were working on a teleost fish species so used "others" <br />
 --sensitive [0|1] Use RepeatModeler to identify remaining TEs (1) or not (0, default), we ran it with RepeatModeler <br />
 --threads Number of threads to run this script (default 4), we ran it with 42 <br />
 Other options are available, see https://github.com/oushujun/EDTA <br />
 
This was tested with Linux Ubuntu (v18.04.5), 32 cores, 64 threads, 128GB RAM on a genome (size c.700MB). <br />
On this system with this genome EDTA ran in c.60 hours. <br />
 
### TE Classification with DeepTE
```
conda activate py36
python [path to DeepTE]DeepTE.py -d [path to working directory] -o [path to output directory] -i [path to EDTA library FASTA] -sp M -m M
exit
```
-d pathway to a working directory where intermediate files for each step are stored <br />
-o pathway to an output directory where output files are stored <br />
-i Input sequences that are unknown TE or DNA sequences, in this case your EDTA made TE library <br />
-sp [P|M|F|O], P: Plants, M: Metazoans, F: Fungi and O: Others. This was a teleost fish species so M <br />
-m [P|M|F|P|U], this argument directly downloads the desired model directory if -m_dir is used users will need to download the model directory themselves <br />
Other settings are available, see https://github.com/LiLabAtVT/DeepTE <br />

We tested this on the same system used in Step 1 and DeepTE ran in under 12 hours.  <br />

### Header Clean-Up

This is just a simple bash command to clean up the library headers <br />
```
bash
sed -e 's/\(#\).*\(__\)/\1\2/'  [path to DeepTE.fasta] > [path to cleaned up library]
```

## Part 2: Screening for TEs

### TE Screening with [RepeatMasker](https://www.repeatmasker.org)

### RepeatMasker Output Clean-Up

### Parsing RepeatMasker Output with [RM_TRIPS](https://github.com/clbutler/RM_TRIPS)




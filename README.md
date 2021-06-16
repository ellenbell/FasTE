# FasTE
FasTE is designed to be used as a quick user guide for *de novo* transposable element (TE) library generation and subsequent TE screening. Part 1: TE library generation, utilises the packages; Extensive *de novo* TE Annotator (EDTA) and DeepTE which may be used in tandem for *de novo* TE annotation and classification. Part 2: TE screening, demonstrates how newly made libraries can be used in conjunction with RepeaMasker for repeat detection and outputs parsed with RM_TRIPS prior to downstream analysis. 

<img width="1073" alt="Screenshot 2021-06-16 at 10 31 21" src="https://user-images.githubusercontent.com/46861035/122195221-118c0900-ce8e-11eb-8427-6b1c5e4a4fd6.png">



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
Find the .yml file in the folder and run <br />
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

 --genome [file]                  Path to genome FASTA file 
 --species [rice|Maize|others]    In this instance we were working on a teleost fish species so used "others" 
 --sensitive [0|1]                Use RepeatModeler to identify remaining TEs (1) or not (0, default), we ran it with RepeatModeler 
 --threads                        Number of threads to run this script (default 4), we ran it with 42 

Other settings are available, see https://github.com/oushujun/EDTA 
 ```

This was tested with Linux Ubuntu (v18.04.5), 32 cores, 64 threads, 128GB RAM on a genome (size c.700MB). <br />
On this system with this genome EDTA ran in c.60 hours. <br />
 
### TE Classification with DeepTE
```
conda activate py36
python [path to DeepTE]DeepTE.py -d [path to working directory] -o [path to output directory] -i [path to EDTA library FASTA] -sp M -m M
exit

-d               Pathway to a working directory where intermediate files for each step are stored
-o               Pathway to an output directory where output files are stored
-i               Input sequences that are unknown TE or DNA sequences, in this case your EDTA made TE library
-sp [P|M|F|O]    P: Plants, M: Metazoans, F: Fungi and O: Others. This was a teleost fish species so M was used
-m [P|M|F|P|U]   This argument directly downloads the desired model directory if -m_dir is used users will need to download the model directory themselves

Other settings are available, see https://github.com/LiLabAtVT/DeepTE
```

We tested this on the same system as that used for EDTA and DeepTE ran in under 12 hours.  <br />

### Header Clean-Up

The headers in the output from DeepTE contain some information that is now surplus to requirement. This can be removed by running the following bash command to clean up the library headers <br />
```
bash
sed -e 's/\(#\).*\(__\)/\1\2/'  [path to DeepTE.fasta] > [path to cleaned up library]
```

## Part 2: Screening for TEs

### TE Screening with [RepeatMasker](https://www.repeatmasker.org)
```
[pathway to RepeatMasker]RepeatMasker [pathway to the FASTA genome/transcriptome to be screened] -pa 48 -s -a -lib [pathway to the final EDTA/DeepTE FASTA library] -dir .

-pa           Gives the number of processess to use in parallel, in this case 48
-s [s|q|qq]   RepeatMasker is able to operate at different sensitivities/speeds with -q providing a quick, less sensitive screening and -s providing a slow and more sensivite screening, we used this more sensitive screening option
-a            Is an output option that shows alignments in a .align output file
-lib          Specifies that there is a de novo repeat library you wish to use instead of RepBase

Other settings are available, see https://www.repeatmasker.org
```

### RepeatMasker Output Clean-Up

RepeatMasker uses asterisks in its .out file to label repeats that overlap with one or more other hits that have a higher score. To create a list of distinct repeat hits the following bash command can be used to remove lines with an asterisk in them.  <br />
```
bash
awk '!/\*/' [repeatmasker.out] > [noasterisk_repeatmasker.out]
```
When using *de novo* libraries RepeatMasker sometimes also adds a superfluous -int notation to the TE name which can interfere with downstream parsing, these can be removed with the following bash command. <br />
```
bash
sed 's/-int//' [noasterisk_repeatmasker.out] > [tidy_noasterisk_repeatmasker.out]
```
### Parsing RepeatMasker Output with [RM_TRIPS](https://github.com/clbutler/RM_TRIPS)

Cleaned RepeatMasker output files will need to be further parsed prior to any downstream analysis of TE content. We recommend the use of [RM_TRIPS](https://github.com/clbutler/RM_TRIPS) which is an R based parse script that will; (i) remove repetetive elements not classed as TEs, (ii) merge closely positioned TE fragments of matching identity, (iii) remove duplicated isoforms (from transcriptomic data) and, (iv) remove fragments less then 80 base pairs long. It then outputs a .csv file which can be input for downstream applications. 

### Contact

For questions or queries please contact:

Ellen A Bell - ellen.bell@uea.ac.uk  <br />
Christopher L Butler - c.butler@uea.ac.uk  <br />
Martin I Taylor - martin.taylor@uea.ac.uk <br />

## Citations
Ou, S., Su, W., Liao, Y., Chougule, K., Agda, J. R.A., Hellinga, A. J., …Hufford, M. B. (2019). Benchmarking transposable element annotation methods for creation of a streamlined, comprehensive pipeline. Genome Biology, 20(1), 1–18. doi: 10.1186/s13059-019-1905-y. <br />

Smit, A. F. & Hubley, R. RepeatModeler Open-1.0. Available from: http://www.repeatmasker.org. <br />

Yan, H., Bombarely, A. & Li, S. (2020). DeepTE: a computational method for de novo classification of transposons with convolutional neural network. Bioinformatics, 36(15), 4269–4275. doi: 10.1093/bioinformatics/btaa519. <br />




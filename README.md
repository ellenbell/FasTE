# Quick_TE
This repository is designed to be used as a quick use guide to two packages; the Extensive de novo TE Annotator (EDTA) and DeepTE which may be used in tandem for *de novo* transposable element (TE) library generation. It then provides a walk-through of TE screening with RepeatMasker


## Dependencies

[Extensive de novo TE Annotator (EDTA)](https://github.com/oushujun/EDTA) <br />
[DeepTE](https://github.com/LiLabAtVT/DeepTE) <br />
[RepeatMasker](https://www.repeatmasker.org) <br />
[RM_TRIPS](https://github.com/clbutler/RM_TRIPS) <br />

## Recommended installation for [EDTA] (https://github.com/oushujun/EDTA) <br />

Download the latest EDTA <br />
```
git clone https://github.com/oushujun/EDTA.git
```
Find the yml file in the folder and run <br />
```
conda env create -f EDTA.yml
```
## Recommended installation for [DeepTE](https://github.com/LiLabAtVT/DeepTE) <br />
```
Install conda: https://www.anaconda.com/products/individual
conda create -n py36 python=3.6
conda activate py36
conda install tensorflow-gpu=1.14.0
conda install biopython
conda install keras=2.2.4
conda install numpy=1.16.0
```

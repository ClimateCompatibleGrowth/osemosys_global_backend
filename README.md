# README

### Setting up the linux machine:

```
sudo apt-get update
sudo apt-get install glpk-utils coinor-cbc
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
# ... install Miniconda
conda config --set auto_activate_base false
rm Miniconda3-latest-Linux-x86_64.sh
# From https://github.com/OSeMOSYS/osemosys_global
git clone --recurse-submodules https://github.com/OSeMOSYS/osemosys_global.git
conda env create -f workflow/envs/osemosys-global.yaml
```

Then:

```
# script.sh

eval "$(conda shell.bash hook)"
conda activate osemosys-global
snakemake -c
```

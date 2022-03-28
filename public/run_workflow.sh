#!/bin/bash
set -e

cd /home/ubuntu/osemosys_global/
wget --output-document=/home/ubuntu/osemosys_global/config/config.yaml $1
source /home/ubuntu/miniconda3/bin/activate osemosys-global
snakemake -c

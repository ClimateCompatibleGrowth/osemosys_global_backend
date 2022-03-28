#!/bin/bash
set -e

cd /home/ubuntu/osemosys_global/
# To do: name argument something else than $1
wget --output-document=/home/ubuntu/osemosys_global/config/config.yaml $1
source /home/ubuntu/miniconda3/bin/activate osemosys-global
snakemake -c
# curl --request PUT \
#   --url http://localhost:3000/runs/[slug] \
#   --form 'result_file=@/home/ubuntu/osemosys_global/config/config.yaml'

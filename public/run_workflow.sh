#!/bin/bash
set -e

# Verbose for debugging
set -x

if [ "$#" -ne 1 ]; then
  echo "Illegal number of parameters"
  exit
fi
config_file_url=$1

cd /home/ubuntu/osemosys_global/

# Pin the version
git reset --hard && git pull
git reset --hard 70f7f5cd7

# Update conda environment
# conda env update -f workflow/envs/osemosys-global.yaml 

wget --output-document=/home/ubuntu/osemosys_global/config/config.yaml $config_file_url
source /home/ubuntu/miniconda3/bin/activate osemosys-global
timeout 1h snakemake -c
# curl --request PUT \
#   --url http://localhost:3000/runs/[slug] \
#   --form 'result_file=@/home/ubuntu/osemosys_global/config/config.yaml'

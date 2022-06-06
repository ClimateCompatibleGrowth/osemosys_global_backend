#!/bin/bash
set -e

# Verbose for debugging
set -x

if [ "$#" -ne 1 ]; then
  echo "Illegal number of parameters"
  exit
fi

config_file_url=$1
config_file_path="/home/ubuntu/osemosys_global/config/config.yaml"
api_url="https://osemosys-global-backend.herokuapp.com"

cd /home/ubuntu/osemosys_global/

# Pin the version
git reset --hard && git pull
git reset --hard a7ac030c2

# Update conda environment
# conda env update -f workflow/envs/osemosys-global.yaml 

wget --output-document=$config_file_path $config_file_url
source /home/ubuntu/miniconda3/bin/activate osemosys-global
snakemake_exit_code=0
timeout 1h snakemake -c || snakemake_exit_code=$?

upload_results () {
  scenario_name=$(yq '.scenario' $config_file_path)
  user_defined_capacity=$(yq '.user_defined_capacity' $config_file_path)
  run_slug=$(yq '.slug' $config_file_path)

  if [ "$user_defined_capacity" == 'null' ]; then
    interconnector_enabled=false
  else
    interconnector_enabled=true
  fi

  if [ "$interconnector_enabled" == true ]; then
    capacities_attachment_name="capacities_with_interconnector"
    generation_attachment_name="generation_with_interconnector"
    metrics_attachment_name="metrics_with_interconnector"
    trade_flows_attachment_name="trade_flows_with_interconnector"
  else
    capacities_attachment_name="capacities_without_interconnector"
    generation_attachment_name="generation_without_interconnector"
    metrics_attachment_name="metrics_without_interconnector"
    trade_flows_attachment_name="trade_flows_without_interconnector"
  fi

  # Only do this if success
  curl --request PUT \
    --url "${api_url}/runs/${run_slug}" \
    --form "${capacities_attachment_name}=@/home/ubuntu/osemosys_global/results/${scenario_name}/result_summaries/Capacities.csv" \
    --form "${generation_attachment_name}=@/home/ubuntu/osemosys_global/results/${scenario_name}/result_summaries/Generation.csv" \
    --form "${metrics_attachment_name}=@/home/ubuntu/osemosys_global/results/${scenario_name}/result_summaries/Metrics.csv" \
    --form "${trade_flows_attachment_name}=@/home/ubuntu/osemosys_global/results/${scenario_name}/result_summaries/TradeFlows.csv"
}


if [ "$snakemake_exit_code" == 0 ]; then
  upload_results
else
  echo "Snakemake failed, skipping result upload. Maybe upload log here?"
fi

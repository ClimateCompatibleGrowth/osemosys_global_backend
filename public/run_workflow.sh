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
scenario_name=$(yq '.scenario' $config_file_path)
interconnector_enabled=$(yq '.interconnector_enabled' $config_file_path)
run_slug=$(yq '.slug' $config_file_path)

cd /home/ubuntu/osemosys_global/

# Pin the version
git reset --hard && git pull
git reset --hard 8df3389

# Update conda environment
/home/ubuntu/miniconda3/bin/conda env update -f workflow/envs/osemosys-global.yaml 

wget --output-document=$config_file_path $config_file_url
source /home/ubuntu/miniconda3/bin/activate osemosys-global
snakemake_exit_code=0
timeout 10h snakemake -c || snakemake_exit_code=$?

upload_results () {
  if [ "$interconnector_enabled" == true ]; then
    capacities_attachment_name="capacities_with_interconnector"
    generation_attachment_name="generation_with_interconnector"
    generation_by_node_attachment_name="generation_by_node_with_interconnector"
    metrics_attachment_name="metrics_with_interconnector"
    trade_flows_attachment_name="trade_flows_with_interconnector"
    log_attachement_name="log_with_interconnector"
  else
    capacities_attachment_name="capacities_without_interconnector"
    generation_attachment_name="generation_without_interconnector"
    generation_by_node_attachment_name="generation_by_node_without_interconnector"
    metrics_attachment_name="metrics_without_interconnector"
    trade_flows_attachment_name="trade_flows_without_interconnector"
    log_attachement_name="log_without_interconnector"
  fi

  curl --request PUT \
    --url "${api_url}/runs/${run_slug}" \
    --form "${capacities_attachment_name}=@/home/ubuntu/osemosys_global/results/${scenario_name}/result_summaries/Capacities.csv" \
    --form "${generation_attachment_name}=@/home/ubuntu/osemosys_global/results/${scenario_name}/result_summaries/Generation.csv" \
    --form "${generation_by_node_attachment_name}=@/home/ubuntu/osemosys_global/results/${scenario_name}/result_summaries/Generation_By_Node.csv" \
    --form "${metrics_attachment_name}=@/home/ubuntu/osemosys_global/results/${scenario_name}/result_summaries/Metrics.csv" \
    --form "${log_attachement_name}=@/var/log/cloud-init-output.log" \
    --form "${trade_flows_attachment_name}=@/home/ubuntu/osemosys_global/results/${scenario_name}/result_summaries/TradeFlows.csv"
}

upload_logs_on_failure () {
  if [ "$interconnector_enabled" == true ]; then
    log_attachement_name="log_with_interconnector"
  else
    log_attachement_name="log_without_interconnector"
  fi

  curl --request PUT \
    --url "${api_url}/runs/${run_slug}" \
    --form "${log_attachement_name}=@/var/log/cloud-init-output.log"
}

if [ "$snakemake_exit_code" == 0 ]; then
  upload_results
else
  echo "Snakemake failed, skipping result upload. Uploading logs."
  upload_logs_on_failure
fi

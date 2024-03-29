json.(
  run,
  :id,
  :interconnector_nodes,
  :capacity,
  :start_year,
  :end_year,
  :resolution,
  :slug,
  :email,
  :geographic_scope,
  :status,
  :parameter_rows,
)

json.results do
  json.with_interconnector do
    json.capacities attachment_url_or_nil_for(run.capacities_with_interconnector)
    json.generation attachment_url_or_nil_for(run.generation_with_interconnector)
    json.generation_by_node attachment_url_or_nil_for(run.generation_by_node_with_interconnector)
    json.metrics attachment_url_or_nil_for(run.metrics_with_interconnector)
    json.trade_flows attachment_url_or_nil_for(run.trade_flows_with_interconnector)
    json.log attachment_url_or_nil_for(run.log_with_interconnector)
  end

  json.without_interconnector do
    json.capacities attachment_url_or_nil_for(run.capacities_without_interconnector)
    json.generation attachment_url_or_nil_for(run.generation_without_interconnector)
    json.generation_by_node attachment_url_or_nil_for(run.generation_by_node_without_interconnector)
    json.metrics attachment_url_or_nil_for(run.metrics_without_interconnector)
    json.trade_flows attachment_url_or_nil_for(run.trade_flows_without_interconnector)
    json.log attachment_url_or_nil_for(run.log_without_interconnector)
  end
end

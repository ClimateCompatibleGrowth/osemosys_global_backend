ParameterRow = Struct.new(
  :id,
  :type,
  :capacity,
  :start_year,
  :end_year,
  :interconnector_nodes,
  keyword_init: true,
) do
  def user_defined_technology_name
    short_nodes = interconnector_nodes.sort.map { |node| node.split('-')[1..].join }
    "TRN#{short_nodes.join}"
  end

  def geographic_scope
    interconnector_nodes.map { |node| node.split('-')[1] }.uniq
  end
end

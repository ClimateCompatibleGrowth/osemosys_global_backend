require 'rails_helper'

RSpec.describe ParameterRow do
  describe '#user_defined_technology_name' do
    it 'converts the node names to user defined techonology' do
      node1 = 'AS-IND-EA'
      node2 = 'AS-IND-SO'
      parameter_row = build(:parameter_row, interconnector_nodes: [node1, node2])

      expect(parameter_row.user_defined_technology_name).to eq('TRNINDEAINDSO')
    end

    it 'sorts the nodes alphabetically' do
      node1 = 'AS-XYZ-XX'
      node2 = 'AS-ABC-XX'
      parameter_row = build(:parameter_row, interconnector_nodes: [node1, node2])

      expect(parameter_row.user_defined_technology_name).to eq('TRNABCXXXYZXX')
    end
  end
end

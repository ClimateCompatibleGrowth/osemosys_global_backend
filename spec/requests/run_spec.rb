require 'rails_helper'

RSpec.describe 'Run queries' do
  describe 'GET show in json' do
    it 'renders the run' do
      run = create(
        :run,
        node1: 'Node1',
        node2: 'Node2',
        capacity: 99,
        start_year: 2019,
        end_year: 2029,
        resolution: {
          day_parts: [
            { id: 'Morning', start_hour: 0, end_hour: 12 },
            { id: 'Night', start_hour: 12, end_hour: 24 },
          ],
          seasons: [
            { id: 'Winter', months: [1, 2, 3, 4, 5, 6] },
            { id: 'Summer', months: [7, 8, 9, 10, 11, 12] },
          ],
        },
        slug: 'a-slug',
      )

      get "/runs/#{run.id}.json"

      result = JSON.parse(response.body).symbolize_keys
      expect(result[:id]).to eq(run.id)
      expect(result[:node1]).to eq('Node1')
      expect(result[:node2]).to eq('Node2')
      expect(result[:capacity]).to eq(99)
      expect(result[:start_year]).to eq(2019)
      expect(result[:end_year]).to eq(2029)
      expect(result[:resolution]).to eq(
        'day_parts' => [
          { 'id' => 'Morning', 'start_hour' => 0, 'end_hour' => 12 },
          { 'id' => 'Night', 'start_hour' => 12, 'end_hour' => 24 },
        ],
        'seasons' => [
          { 'id' => 'Winter', 'months' => [1, 2, 3, 4, 5, 6] },
          { 'id' => 'Summer', 'months' => [7, 8, 9, 10, 11, 12] },
        ],
      )
      expect(result[:slug]).to eq('a-slug')
    end
  end

  describe 'GET show in yaml' do
    it 'renders the run' do
      run = create(:run)

      get "/runs/#{run.id}.yml"

      # result = YAML.load(response.body).symbolize_keys
      expect(response.body).to include("Auto-generated config for run #{run.id}")
    end
  end
end

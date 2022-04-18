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
        geographic_scope: %w[AFR EUR],
      )

      get "/runs/#{run.slug}.json"

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
      expect(result[:geographic_scope]).to eq(%w[AFR EUR])
    end

    it 'renders a 404 if the run is not found' do
      get '/runs/a-slug.json'

      expect(response.code).to eq('404')
      result = JSON.parse(response.body).symbolize_keys
      expect(result).to eq(
        error: 'No run with that slug found.',
      )
    end
  end

  describe 'GET show in yaml' do
    it 'renders the run' do
      run = create(:run)

      get "/runs/#{run.slug}.yml"

      parsed_result = YAML.safe_load(response.body).symbolize_keys
      expect(response.body).to include("Auto-generated config for run #{run.id}")
      expect(parsed_result[:scenario]).to eq(run.slug)
      expect(parsed_result[:startYear]).to eq(run.start_year)
      expect(parsed_result[:endYear]).to eq(run.end_year)
      expect(parsed_result[:unused_nodes]).to eq([run.node1, run.node2])
      expect(parsed_result[:geographic_scope]).to eq(['IND'])
      expect(parsed_result[:dayparts].keys).to eq(run.day_parts.map { |day_part| day_part['id'] })
      expect(parsed_result[:dayparts].values).to eq(
        run.day_parts.map { |day_part| [day_part['start_hour'], day_part['end_hour']] },
      )
      expect(parsed_result[:seasons].keys).to eq(run.seasons.map { |season| season['id'] })
      expect(parsed_result[:seasons].values).to eq(run.seasons.map { |season| season['months'] })
    end
  end

  describe 'POST create' do
    it 'creates a run when the params are valid' do
      post '/runs',
        as: :json,
        params: {
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
          geographic_scope: %w[AFR EUR],
        }

      expect(Run.count).to eq(1)
      result = JSON.parse(response.body).symbolize_keys
      expect(result).to include(
        node1: 'Node1',
        node2: 'Node2',
        capacity: 99,
        start_year: 2019,
        end_year: 2029,
        resolution: {
          'day_parts' => [
            { 'id' => 'Morning', 'start_hour' => 0, 'end_hour' => 12 },
            { 'id' => 'Night', 'start_hour' => 12, 'end_hour' => 24 },
          ],
          'seasons' => [
            { 'id' => 'Winter', 'months' => [1, 2, 3, 4, 5, 6] },
            { 'id' => 'Summer', 'months' => [7, 8, 9, 10, 11, 12] },
          ],
        },
        slug: match('node1-node2-99-2029'),
        geographic_scope: %w[AFR EUR],
      )
    end

    it 'returns an error message when the params are invalid' do
      post '/runs', as: :json, params: {}

      expect(Run.count).to eq(0)
      expect(response.code).to eq('400')
      result = JSON.parse(response.body).symbolize_keys
      expect(result).to include(errors: match("Node1 can't be blank"))
      expect(result).to include(errors: match("Node2 can't be blank"))
      expect(result).to include(errors: match("Capacity can't be blank"))
      expect(result).to include(errors: match("Start year can't be blank"))
      expect(result).to include(errors: match("End year can't be blank"))
    end
  end

  describe 'PUT update' do
    it 'updates the run with the new attributes' do
      run = create(:run, email: 'old-email@example.com')

      put "/runs/#{run.slug}",
        as: :json,
        params: { email: 'new-email@example.com' }

      run.reload
      expect(run.email).to eq('new-email@example.com')
      result = JSON.parse(response.body).symbolize_keys
      expect(result).to include(email: 'new-email@example.com')
    end

    it 'returns an error message when the run slug is invalid' do
      post '/runs', as: :json, params: {}

      put '/runs/invalid',
        as: :json,
        params: { email: 'new-email@example.com' }

      expect(Run.count).to eq(0)
      expect(response.code).to eq('404')
      result = JSON.parse(response.body).symbolize_keys
      expect(result).to eq(error: 'No run with that slug found.')
    end

    it 'returns an error message when the email is invalid' do
      run = create(:run, email: 'old-email@example.com')

      put "/runs/#{run.slug}",
        as: :json,
        params: { email: 'invalid' }

      expect(response.code).to eq('400')
      result = JSON.parse(response.body).symbolize_keys
      expect(result).to include(errors: match('Email is invalid'))
    end
  end
end

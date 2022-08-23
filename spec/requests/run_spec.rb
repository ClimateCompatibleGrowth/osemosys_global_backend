require 'rails_helper'

RSpec.describe 'Run queries' do
  describe 'GET show in json' do
    it 'renders the run' do
      run = create(
        :run,
        interconnector_nodes: %w[Node1 Node2],
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
      run.capacities_with_interconnector.attach(
        io: File.open(Rails.root.join('spec/fixtures/test_result.csv')),
        filename: 'test.csv',
      )

      get "/runs/#{run.slug}.json"

      result = JSON.parse(response.body).symbolize_keys
      expect(result[:id]).to eq(run.id)
      expect(result[:interconnector_nodes]).to eq(%w[Node1 Node2])
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
      expect(result[:status]).to eq('pending')
      expect(result.dig(:results, 'with_interconnector', 'capacities')).to be_present
      expect(result.dig(:results, 'without_interconnector', 'capacities')).not_to be_present
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
    it 'renders the run with one interconnector' do
      run = create(
        :run,
        parameter_rows: [
          {
            interconnector_nodes: %w[US-REG1-NO US-REG2],
            capacity: 1,
            start_year: 2020,
            end_year: 2050,
          },
        ],
      )

      get "/runs/#{run.slug}.yml"

      parsed_result = YAML.safe_load(response.body).symbolize_keys
      expect(response.body).to include("Auto-generated config for run #{run.id}")
      expect(parsed_result[:scenario]).to eq(run.slug)
      expect(parsed_result[:slug]).to eq(run.slug)
      expect(parsed_result[:geographic_scope]).to match_array(%w[REG1 REG2])
      expect(parsed_result[:user_defined_capacity].keys.first).to eq('TRNREG1NOREG2')
      expect(parsed_result[:user_defined_capacity].values.first).to eq(
        [1, 2020],
      )
      expect(parsed_result[:dayparts].keys).to eq(run.day_parts.map { |day_part| day_part['id'] })
      expect(parsed_result[:dayparts].values).to eq(
        run.day_parts.map { |day_part| [day_part['start_hour'], day_part['end_hour']] },
      )
      expect(parsed_result[:seasons].keys).to eq(run.seasons.map { |season| season['id'] })
      expect(parsed_result[:seasons].values).to eq(run.seasons.map { |season| season['months'] })
    end

    it 'supports multiple interconnectors' do
      run = create(
        :run,
        parameter_rows: [
          {
            interconnector_nodes: %w[US-REG1-NO US-REG2],
            capacity: 1,
            start_year: 2020,
          },
          {
            interconnector_nodes: %w[US-REG2-NO US-REG3],
            capacity: 2,
            start_year: 2021,
          },
        ],
      )

      get "/runs/#{run.slug}.yml"

      parsed_result = YAML.safe_load(response.body).symbolize_keys
      expect(parsed_result[:geographic_scope]).to match_array(%w[REG1 REG2 REG3])
      expect(parsed_result[:user_defined_capacity].keys.first).to eq('TRNREG1NOREG2')
      expect(parsed_result[:user_defined_capacity].keys.last).to eq('TRNREG2NOREG3')
      expect(parsed_result[:user_defined_capacity].values.first).to eq(
        [1, 2020],
      )
      expect(parsed_result[:user_defined_capacity].values.last).to eq(
        [2, 2021],
      )
    end

    it 'renders the run without the interconnector when disabled' do
      run = create(
        :run,
        parameter_rows: [
          {
            capacity: 99, start_year: 2_099, interconnector_nodes: %w[AS-IND-EA AS-IND-NP]
          },
        ],
      )

      get "/runs/#{run.slug}.yml?disable_interconnector=true"

      parsed_result = YAML.safe_load(response.body).symbolize_keys
      expect(parsed_result[:user_defined_capacity].values.first).to eq([0, 2099])
    end

    it 'renders the run with the interconnector when false is passed' do
      run = create(
        :run,
        parameter_rows: [
          {
            capacity: 99, start_year: 2_099, interconnector_nodes: %w[AS-IND-EA AS-IND-NP]
          },
        ],
      )

      get "/runs/#{run.slug}.yml?disable_interconnector=false"

      parsed_result = YAML.safe_load(response.body).symbolize_keys
      expect(parsed_result[:user_defined_capacity].values.first).to eq([99, 2099])
    end
  end

  describe 'POST create' do
    it 'creates a run when the params are valid' do
      post '/runs',
        as: :json,
        params: {
          interconnector_nodes: %w[Node1 Node2],
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
          parameter_rows: [
            {
              id: 0,
              type: 'interconnector',
              interconnector_nodes: %w[AF-AGO-XX AF-COD-XX],
              capacity: 1,
              start_year: 2020,
              end_year: 2050,
            },
          ],
        }

      expect(Run.count).to eq(1)
      result = JSON.parse(response.body).deep_symbolize_keys
      expect(result).to include(
        interconnector_nodes: %w[Node1 Node2],
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
        slug: match('node1-node2-99-2029'),
        geographic_scope: %w[AFR EUR],
        parameter_rows: [
          {
            id: 0,
            type: 'interconnector',
            interconnector_nodes: %w[AF-AGO-XX AF-COD-XX],
            capacity: 1,
            start_year: 2020,
            end_year: 2050,
          },
        ],
      )
    end

    it 'returns an error message when the params are invalid' do
      post '/runs', as: :json, params: {}

      expect(Run.count).to eq(0)
      expect(response.code).to eq('400')
      result = JSON.parse(response.body).symbolize_keys
      expect(result).to include(errors: match("Interconnector nodes can't be blank"))
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

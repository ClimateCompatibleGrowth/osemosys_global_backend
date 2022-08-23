require 'rails_helper'

RSpec.describe Run do
  describe 'before_validation callbacks' do
    it 'generates a slug' do
      run = build(:run, interconnector_nodes: %w[ND1 ND2], capacity: '88', end_year: 3000)

      run.validate

      expect(run.slug).to match('nd1-nd2-88-3000-')
    end

    it 'does not override existing slugs' do
      run = build(:run, slug: 'existing-slug')

      run.validate

      expect(run.slug).to eq('existing-slug')
    end
  end

  describe 'before_save callbacks' do
    it 'sets the status to completed if both runs are finished' do
      run = build(
        :run,
        with_interconnector_finished_at: 2.minutes.ago,
        without_interconnector_finished_at: 2.minutes.ago,
      )

      run.save

      expect(run.status).to eq('completed')
    end

    it 'does not set the status to completed if one of the runs is not finished' do
      run = build(
        :run,
        with_interconnector_finished_at: nil,
        without_interconnector_finished_at: 2.minutes.ago,
      )

      run.save

      expect(run.status).not_to eq('completed')
    end
  end

  describe 'validations' do
    it 'enforces correct sesaons' do
      run_with_malformed_seasons = build(
        :run,
        resolution: { seasons: 'something' },
      )
      run_with_missing_season_fields = build(
        :run,
        seasons: [{ months: (1..12).to_a }],
      )
      valid_run = build(
        :run,
        seasons: [{ months: (1..12).to_a, id: 'year' }],
      )

      expect(run_with_malformed_seasons).to be_invalid
      expect(run_with_malformed_seasons.errors[:resolution]).to include(
        'Seasons are not in the correct format.',
      )
      expect(run_with_missing_season_fields).to be_invalid
      expect(run_with_missing_season_fields.errors[:resolution]).to include(
        'Seasons are not in the correct format.',
      )
      expect(valid_run).to be_valid
    end

    it 'enforces correct day parts' do
      run_with_malformed_day_parts = build(
        :run,
        day_parts: 'something',
      )
      run_with_missing_day_part_fields = build(
        :run,
        day_parts: [{ id: 'Morning', end_hour: 24 }],
      )
      valid_run = build(
        :run,
        day_parts: [{ id: 'Morning', start_hour: 0, end_hour: 24 }],
      )

      expect(run_with_malformed_day_parts).to be_invalid
      expect(run_with_malformed_day_parts.errors[:resolution]).to include(
        'Day parts are not in the correct format.',
      )
      expect(run_with_missing_day_part_fields).to be_invalid
      expect(run_with_missing_day_part_fields.errors[:resolution]).to include(
        'Day parts are not in the correct format.',
      )
      expect(valid_run).to be_valid
    end
  end

  describe 'resolution' do
    it 'has helper methods for day_parts and seasons' do
      run = build(
        :run,
        resolution: {
          day_parts: [
            { id: 'Night', start_hour: 0, end_hour: 12 },
            { id: 'Day', start_hour: 12, end_hour: 24 },
          ],
          seasons: [
            { id: 'Winter', months: [1, 2, 3, 4, 5, 6] },
            { id: 'Summer', months: [7, 8, 9, 10, 11, 12] },
          ],
        },
      )

      expect(run.day_parts).to eq(
        [
          { id: 'Night', start_hour: 0, end_hour: 12 },
          { id: 'Day', start_hour: 12, end_hour: 24 },
        ].map(&:stringify_keys),
      )
      expect(run.seasons).to eq(
        [
          { id: 'Winter', months: [1, 2, 3, 4, 5, 6] },
          { id: 'Summer', months: [7, 8, 9, 10, 11, 12] },
        ].map(&:stringify_keys),
      )
    end
  end

  describe '#user_defined_technology_name' do
    it 'converts the node names to user defined techonology' do
      node1 = 'AS-IND-EA'
      node2 = 'AS-IND-SO'
      run = build(:run, interconnector_nodes: [node1, node2])

      expect(run.user_defined_technology_name).to eq('TRNINDEAINDSO')
    end

    it 'sorts the nodes alphabetically' do
      node1 = 'AS-XYZ-XX'
      node2 = 'AS-ABC-XX'
      run = build(:run, interconnector_nodes: [node1, node2])

      expect(run.user_defined_technology_name).to eq('TRNABCXXXYZXX')
    end
  end

  describe '#generated_geographic_scope' do
    it 'converts the node names to geographic scope' do
      node1 = 'AS-IND-EA'
      node2 = 'AS-NPL'
      run = build(
        :run,
        parameter_rows: [
          { interconnector_nodes: [node1, node2] },
          { interconnector_nodes: [node2, node1] },
        ],
      )

      expect(run.generated_geographic_scope).to match_array(%w[IND NPL])
    end

    it 'excludes duplicates' do
      node1 = 'AS-IND-EA'
      node2 = 'AS-IND-SO'
      run = build(
        :run,
        parameter_rows: [
          { interconnector_nodes: [node1, node2] },
          { interconnector_nodes: [node2, node1] },
        ],
      )

      expect(run.generated_geographic_scope).to match_array(%w[IND])
    end
  end

  describe '#parsed_paramater_rows' do
    it 'is an array of `ParameterRow` objects' do
      run = build(
        :run,
        parameter_rows: [
          {
            id: 0,
            type: 'interconnector',
            interconnector_nodes: %w[AF-AGO-XX AF-COD-XX],
            capacity: 20,
            start_year: 2020,
            end_year: 2050,
          },
          {
            id: 1,
            type: 'interconnector',
            interconnector_nodes: %w[AF-JPN-XX AF-KOR-XX],
            capacity: 30,
            start_year: 2020,
            end_year: 2050,
          },
        ],
      )

      result = run.parsed_parameter_rows

      expect(result.count).to eq(2)
      first_row = result.last
      expect(first_row).to be_a(ParameterRow)
      expect(first_row.type).to eq('interconnector')
      expect(first_row.interconnector_nodes).to eq(%w[AF-JPN-XX AF-KOR-XX])
      expect(first_row.capacity).to eq(30)
      expect(first_row.start_year).to eq(2020)
      expect(first_row.end_year).to eq(2050)
    end
  end
end

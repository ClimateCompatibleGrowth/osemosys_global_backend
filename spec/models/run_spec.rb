require 'rails_helper'

RSpec.describe Run do
  describe 'before_validation callbacks' do
    it 'generates a slug' do
      run = build(:run, node1: 'ND1', node2: 'ND2', capacity: '88', end_year: 3000)

      run.validate

      expect(run.slug).to match('nd1-nd2-88-3000-')
    end
  end

  describe 'validations' do
    it 'enforces correct seaons' do
      run_with_malformed_seasons = build(
        :run,
        resolution: { seasons: 'something' },
      )
      run_with_missing_season_fields = build(
        :run,
        resolution: { seasons: [{ months: (1..12).to_a }] },
      )
      run_with_incomplete_coverage = build(
        :run,
        resolution: { seasons: [{ months: (1..11).to_a, id: 'year' }] },
      )
      valid_run = build(
        :run,
        resolution: { seasons: [{ months: (1..12).to_a, id: 'year' }] },
      )

      expect(run_with_malformed_seasons).to be_invalid
      expect(run_with_malformed_seasons.errors[:resolution]).to include(
        'Seasons are not in the correct format.',
      )
      expect(run_with_missing_season_fields).to be_invalid
      expect(run_with_missing_season_fields.errors[:resolution]).to include(
        'Seasons are not in the correct format.',
      )
      expect(run_with_incomplete_coverage).to be_invalid
      expect(run_with_incomplete_coverage.errors[:resolution]).to include(
        'Seasons are not in the correct format.',
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
end

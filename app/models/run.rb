class Run < ApplicationRecord
  before_validation :generate_slug

  validates :node1, :node2, :capacity, :start_year, :end_year, :slug, presence: true
  validate :enforce_season_format

  store :resolution, accessors: %i[day_parts seasons], coder: JSON

  private

  def generate_slug
    self.slug = [node1, node2, capacity, end_year, SecureRandom.hex(3)].join('-').parameterize
  end

  def enforce_season_format
    return if seasons.is_a?(Array) && seasons.all? { |season| valid_season?(season) }

    errors.add(:resolution, 'Seasons are not in the correct format.')
  end

  def valid_season?(season)
    season.keys.map(&:to_s).sort == %w[id months] &&
      season['months'].map(&:to_i).flatten.count == 12
  end
end

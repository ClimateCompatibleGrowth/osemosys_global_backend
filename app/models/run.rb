class Run < ApplicationRecord
  before_validation :generate_slug
  after_commit :enqueue_solve_run, on: :create

  validates :node1, :node2, :capacity, :start_year, :end_year, :slug, presence: true
  validate :enforce_season_format
  validate :enforce_day_parts_format

  store_accessor :resolution, %i[day_parts seasons]

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, allow_nil: true

  has_one_attached :capacities_with_interconnector
  has_one_attached :capacities_without_interconnector
  has_one_attached :generation_with_interconnector
  has_one_attached :generation_without_interconnector
  has_one_attached :metrics_with_interconnector
  has_one_attached :metrics_without_interconnector
  has_one_attached :trade_flows_with_interconnector
  has_one_attached :trade_flows_without_interconnector

  enum status: {
    pending: 'pending',
    ongoing: 'ongoing',
    succeeded: 'succeeded',
    failed: 'failed',
  }

  def lifetime
    end_year - start_year
  end

  def user_defined_technology_name
    "TRN#{node1}#{node2}"
  end

  private

  def generate_slug
    return if slug.present?

    self.slug = [node1, node2, capacity, end_year, SecureRandom.hex(3)].join('-').parameterize
  end

  def enforce_day_parts_format
    return if day_parts.is_a?(Array) && day_parts.all? { |day_part| valid_day_part?(day_part) }

    errors.add(:resolution, 'Day parts are not in the correct format.')
  end

  def enforce_season_format
    return if seasons.is_a?(Array) && seasons.all? { |season| valid_season?(season) }

    errors.add(:resolution, 'Seasons are not in the correct format.')
  end

  def valid_season?(season)
    season.keys.map(&:to_s).sort == %w[id months]
  end

  def valid_day_part?(day_part)
    day_part.keys.map(&:to_s).sort == %w[end_hour id start_hour]
  end

  def enqueue_solve_run
    SolveRunOnEc2.perform_async(id)
  end
end

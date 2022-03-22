class Run < ApplicationRecord
  before_validation :generate_slug

  validates :node1, :node2, :capacity, :start_year, :end_year, :slug, presence: true

  private

  def generate_slug
    self.slug = [node1, node2, capacity, end_year, SecureRandom.hex(3)].join('-').parameterize
  end
end

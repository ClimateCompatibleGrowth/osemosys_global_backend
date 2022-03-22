class Run < ApplicationRecord
  validates :node1, :node2, :capacity, :start_year, :end_year, :slug, presence: true
end

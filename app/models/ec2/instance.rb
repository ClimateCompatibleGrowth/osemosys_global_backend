module Ec2
  class Instance < ApplicationRecord
    belongs_to :run
  end
end

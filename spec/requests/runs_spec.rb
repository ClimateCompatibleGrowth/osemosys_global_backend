require 'rails_helper'

RSpec.describe 'Run management' do
  describe 'GET index' do
    it 'renders the last 10 runs' do
      15.times { Run.create! }

      get '/runs.json'

      result = JSON.parse(response.body)
      expect(result.count).to eq(10)
      expect(result.map { |run| run['id'] }).to match_array(Run.last(10).pluck(:id))
    end
  end
end

require 'rails_helper'

RSpec.describe 'Run queries' do
  describe 'GET show in json' do
    it 'renders the run' do
      run = create(:run)

      get "/runs/#{run.id}.json"

      result = JSON.parse(response.body).symbolize_keys
      expect(result[:id]).to eq(run.id)
    end
  end

  describe 'GET show in yaml' do
    it 'renders the run' do
      run = create(:run)

      get "/runs/#{run.id}.yml"

      # result = YAML.load(response.body).symbolize_keys
      expect(response.body).to include("Auto-generated config for run #{run.id}")
    end
  end
end

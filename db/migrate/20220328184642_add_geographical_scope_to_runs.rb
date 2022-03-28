class AddGeographicalScopeToRuns < ActiveRecord::Migration[7.0]
  def change
    add_column :runs, :geographic_scope, :string, array: true, null: false, default: []
  end
end

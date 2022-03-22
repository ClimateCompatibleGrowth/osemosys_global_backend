class AddInfoToRuns < ActiveRecord::Migration[7.0]
  def change
    # rubocop:disable Rails/BulkChangeTable
    add_column :runs, :node1, :string, null: false
    add_column :runs, :node2, :string, null: false
    add_column :runs, :capacity, :integer, null: false
    add_column :runs, :start_year, :integer, null: false
    add_column :runs, :end_year, :integer, null: false
    add_column :runs, :resolution, :json, null: false, default: {}
    add_column :runs, :email, :string
    add_column :runs, :slug, :string, null: false
    # rubocop:enable Rails/BulkChangeTable

    add_foreign_key :ec2_instances, :runs
    add_index :runs, :slug, unique: true
  end
end

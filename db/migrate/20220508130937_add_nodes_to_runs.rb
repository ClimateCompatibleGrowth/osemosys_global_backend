class AddNodesToRuns < ActiveRecord::Migration[7.0]
  def change
    add_column :runs, :interconnector_nodes, :string, array: true, default: [], null: false
    change_column_null :runs, :node1, true
    change_column_null :runs, :node2, true

    Run.find_each do |run|
      run.interconnector_nodes = [run.node1, run.node2]
      run.save(validate: false)
    end
  end
end

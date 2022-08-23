class AddParameterRowsToRuns < ActiveRecord::Migration[7.0]
  def change
    add_column :runs, :parameter_rows, :json
  end
end

class CreateRuns < ActiveRecord::Migration[7.0]
  def change
    create_table :runs, &:timestamps
  end
end

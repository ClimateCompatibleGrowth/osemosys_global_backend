class AddFinishedAtToRuns < ActiveRecord::Migration[7.0]
  def change
    # rubocop:disable Rails/BulkChangeTable
    add_column :runs, :with_interconnector_finished_at, :datetime
    add_column :runs, :without_interconnector_finished_at, :datetime
    # rubocop:enable Rails/BulkChangeTable
  end
end

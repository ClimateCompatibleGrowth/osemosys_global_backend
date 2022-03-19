class CreateEc2Instances < ActiveRecord::Migration[7.0]
  def change
    create_table :ec2_instances do |t|
      t.references :run, null: false
      t.datetime :started_at
      t.datetime :stopped_at
      t.string :ip
      t.string :instance_type
      t.string :aws_id

      t.timestamps
    end
  end
end

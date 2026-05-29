class CreateMaintenanceRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :maintenance_records do |t|
      t.text :description, null: false
      t.datetime :performed_at, null: false
      t.references :equipment, null: false, foreign_key: true
      t.timestamps
    end
    add_index :maintenance_records, [:equipment_id, :performed_at]
  end
end
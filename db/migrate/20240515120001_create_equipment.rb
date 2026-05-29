class CreateEquipment < ActiveRecord::Migration[7.1]
  def change
    create_table :equipment do |t|
      t.string :name, null: false
      t.string :serial_number, null: false
      t.string :status, null: false, default: "available"
      t.references :category, null: false, foreign_key: true
      t.timestamps
    end
    add_index :equipment, :serial_number, unique: true
  end
end

class CreateSimsettings < ActiveRecord::Migration[5.2]
  def change
    create_table :simsettings do |t|
      t.float :fuel_capa
      t.float :fuel_per1km
      t.string :fuel_threshold
      t.float :dist_univ
      t.float :dist_holiday
      t.string :probability

      t.timestamps
    end
  end
end

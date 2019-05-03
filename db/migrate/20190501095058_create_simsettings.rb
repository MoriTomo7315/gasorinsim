class CreateSimsettings < ActiveRecord::Migration[5.2]
  def change
    create_table :simsettings do |t|
      t.float :fuel_capa
      t.float :fuel_per1km
      t.float :gas_cheap
      t.float :gas_littlecheap
      t.float :gas_normal
      t.float :gas_littleexpensive
      t.float :gas_expensive

      t.timestamps
    end
  end
end

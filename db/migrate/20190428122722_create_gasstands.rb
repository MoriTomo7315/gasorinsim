class CreateGasstands < ActiveRecord::Migration[5.2]
  def change
    create_table :gasstands do |t|
      t.float :gas_cheap
      t.float :gas_littlecheap
      t.float :gas_normal
      t.float :gas_littleexpensive
      t.float :gas_expensive

      t.timestamps
    end
  end
end

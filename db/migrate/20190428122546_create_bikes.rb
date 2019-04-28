class CreateBikes < ActiveRecord::Migration[5.2]
  def change
    create_table :bikes do |t|
      t.float :fuel_capa
      t.float :fuel_per1km

      t.timestamps
    end
  end
end

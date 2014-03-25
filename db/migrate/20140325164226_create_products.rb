class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.column :name, :varchar
      t.column :price, :float

      t.timestamps
    end
  end
end

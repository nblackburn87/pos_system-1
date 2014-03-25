class CreateCashiers < ActiveRecord::Migration
  def change
    create_table :cashiers do |t|
      t.column :login, :string

      t.timestamps
    end
  end
end

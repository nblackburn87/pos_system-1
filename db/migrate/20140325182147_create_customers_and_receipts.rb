class CreateCustomersAndReceipts < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.column :name, :string
    end

    create_table :receipts do |t|
      t.column :date, :datetime
      t.column :customer_id, :integer
      t.column :cashier_id, :integer
    end

    create_table :purchases do |t|
      t.column :quantity, :integer
      t.column :product_id, :integer
      t.column :receipt_id, :integer
    end
  end
end

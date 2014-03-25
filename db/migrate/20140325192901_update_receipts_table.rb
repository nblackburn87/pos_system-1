class UpdateReceiptsTable < ActiveRecord::Migration
  def change
    remove_column :receipts, :date
    add_timestamps :receipts
  end
end

require 'active_record'

class Receipt < ActiveRecord::Base
  has_many :purchases
  belongs_to :cashier
  belongs_to :customer


  def self.receipts_for_period(start_date, end_date)
    Receipt.where({ created_at: start_date..end_date })
  end

  def total_income
    total = 0.0
    self.purchases.each do |purchase|
      total += purchase.product.price * purchase.quantity
    end
    total
  end
end

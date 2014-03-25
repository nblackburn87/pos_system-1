require 'active_record'

class Receipt < ActiveRecord::Base
  has_many :purchases
  belongs_to :cashier
  belongs_to :customer
end

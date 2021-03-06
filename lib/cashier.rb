require 'active_record'

class Cashier < ActiveRecord::Base
  validates :login, { :uniqueness => true }
  has_many :receipts
end

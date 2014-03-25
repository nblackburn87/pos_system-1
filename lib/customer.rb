require 'active_record'

class Customer < ActiveRecord::Base
  validates :name, { :uniqueness => true }
  has_many :receipts
end

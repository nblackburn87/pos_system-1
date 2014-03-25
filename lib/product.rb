require 'active_record'

class Product < ActiveRecord::Base
  validates :name, { :uniqueness => true }
  has_many :purchases
end

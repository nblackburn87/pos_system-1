require 'active_record'

class Product < ActiveRecord::Base
  validates :name, { :uniqueness => true }
end

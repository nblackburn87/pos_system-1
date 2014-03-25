require 'active_record'

class Purchase < ActiveRecord::Base
  belongs_to :receipt
  belongs_to :product
end

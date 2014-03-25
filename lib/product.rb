require 'active_record'

class Product < ActiveRecord::Base
  I18n.enforce_available_locales = false
  validates :name, { :uniqueness => true }
end

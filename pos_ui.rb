require 'active_record'

require './lib/cashier'
require './lib/customer'
require './lib/product'
require './lib/purchase'

ActiveRecord::Base.establish_connection(YAML::load(File.open('./db/config.yml'))['development'])


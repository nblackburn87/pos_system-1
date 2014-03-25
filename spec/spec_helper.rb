require 'rspec'
require 'active_record'
require 'shoulda-matchers'
require 'pg'

require 'cashier'
require 'customer'
require 'product'
require 'purchase'
require 'receipt'

ActiveRecord::Base.establish_connection(YAML::load(File.open('./db/config.yml'))['test'])

RSpec.configure do |config|
  config.after(:each) do
  end
end

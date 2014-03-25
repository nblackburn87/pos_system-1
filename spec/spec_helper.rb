require 'rspec'
require 'active_record'
# require 'active_record_migrations'
require 'shoulda-matchers'
require 'pg'

require 'cashier'
require 'customer'
require 'product'
require 'purchase'

ActiveRecord::Base.establish_connection(YAML::load(File.open('../db/config.yml'))['test'])

RSpec.configure do |config|
  config.after(:each) do
  end
end

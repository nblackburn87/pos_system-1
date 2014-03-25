require 'spec_helper'

describe Cashier do
  it { should validate_uniqueness_of :login }
  it { should have_many :receipts }
end

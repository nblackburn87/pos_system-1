require 'spec_helper'

describe Cashier do
  it { should validate_uniqueness_of :login }
end

require 'spec_helper'

describe Receipt do
  it { should have_many :purchases }
  it { should belong_to :cashier }
  it { should belong_to :customer }
end

require 'spec_helper'

describe Product do
  it { should validate_uniqueness_of :name}
end

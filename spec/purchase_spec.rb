require 'spec_helper'

describe Purchase do
  it { should belong_to :receipt }
  it { should belong_to :product }
end

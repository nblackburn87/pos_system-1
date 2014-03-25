require 'spec_helper'

describe Receipt do
  it { should have_many :purchases }
  it { should belong_to :cashier }
  it { should belong_to :customer }

  describe '.receipts_for_period' do
    it 'has many receipts' do
      now = Time.now
      (1..4).each do
        Receipt.create
      end
      Receipt.receipts_for_period(now, Time.now).length.should eq 4
    end
  end

  describe '#total_income' do
    it 'totals the income from a receipt' do
      receipt = Receipt.create
      receipt.total_income.should eq 0
    end
  end
end

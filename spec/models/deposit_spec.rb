require 'rails_helper'

RSpec.describe Deposit do
  subject(:deposit) { described_class.new }

  describe 'registrar validation', db: false do
    it 'rejects absent' do
      deposit.registrar = nil
      deposit.validate
      expect(deposit.errors).to be_added(:registrar, :blank)
    end
  end

  context 'with invalid attribute' do
    before :all do
      @deposit = Deposit.new
    end

    it 'should have 0 amount' do
      @deposit.amount.should == 0
    end

    it 'should not be presisted' do
      @deposit.persisted?.should == false
    end

    it 'should replace comma with point for 0' do
      @deposit.amount = '0,0'
      @deposit.amount.should == 0.0
    end

    it 'should replace comma with points' do
      @deposit.amount = '10,11'
      @deposit.amount.should == 10.11
    end

    it 'should work with float as well' do
      @deposit.amount = 0.123
      @deposit.amount.should == 0.123
    end
  end
end

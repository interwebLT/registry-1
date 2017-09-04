require 'rails_helper'

RSpec.describe Invoice do
  subject(:invoice) { described_class.new }

  describe 'buyer name validation', db: false do
    it 'rejects absent' do
      invoice.buyer_name = nil
      invoice.validate
      expect(invoice.errors).to be_added(:buyer_name, :blank)
    end
  end

  describe 'currency validation', db: false do
    it 'rejects absent' do
      invoice.currency = nil
      invoice.validate
      expect(invoice.errors).to be_added(:currency, :blank)
    end
  end

  describe 'due date validation', db: false do
    it 'rejects absent' do
      invoice.due_date = nil
      invoice.validate
      expect(invoice.errors).to be_added(:due_date, :blank)
    end
  end

  describe 'seller name validation', db: false do
    it 'rejects absent' do
      invoice.seller_name = nil
      invoice.validate
      expect(invoice.errors).to be_added(:seller_name, :blank)
    end
  end

  describe 'seller iban validation', db: false do
    it 'rejects absent' do
      invoice.seller_iban = nil
      invoice.validate
      expect(invoice.errors).to be_added(:seller_iban, :blank)
    end
  end

  describe 'vat prc validation', db: false do
    it 'rejects absent' do
      invoice.vat_prc = nil
      invoice.validate
      expect(invoice.errors).to be_added(:vat_prc, :blank)
    end
  end

  describe 'invoice items validation', db: false do
    it 'rejects absent' do
      invoice.invoice_items = []
      invoice.validate
      expect(invoice.errors).to be_added(:invoice_items, :blank)
    end
  end

  describe 'type validation', db: false do
    it 'rejects absent' do
      invoice.invoice_type = nil
      invoice.validate
      expect(invoice.errors).to be_added(:invoice_type, :blank)
    end
  end

  context 'with valid attributes' do
    before :all do
      @invoice = Fabricate(:invoice)
    end

    it 'should be valid' do
      @invoice.valid?
      @invoice.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @invoice = Fabricate(:invoice)
      @invoice.valid?
      @invoice.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @invoice = Fabricate(:invoice)
      @invoice.valid?
      @invoice.errors.full_messages.should match_array([])
    end

    it 'should return correct addresses' do
      @invoice = Fabricate(:invoice)
      @invoice.seller_address.should == 'Paldiski mnt. 123, Tallinn'
    end

    it 'should calculate sums correctly' do
      @invoice = Fabricate(:invoice)
      @invoice.vat_prc.should == BigDecimal.new('0.2')
      @invoice.sum_without_vat.should == BigDecimal.new('300.0')
      @invoice.vat.should == BigDecimal.new('60.0')
      @invoice.sum.should == BigDecimal.new('360.0')

      ii = @invoice.items.first
      ii.item_sum_without_vat.should == BigDecimal.new('150.0')

      ii = @invoice.items.last
      ii.item_sum_without_vat.should == BigDecimal.new('150.0')
    end

    it 'should cancel overdue invoices' do
      Fabricate(:invoice, created_at: Time.zone.now - 35.days, due_date: Time.zone.now - 30.days)
      Invoice.cancel_overdue_invoices
      Invoice.where(cancelled_at: nil).count.should == 1
    end

    it 'should have one version' do
      with_versioning do
        @invoice.versions.should == []
        @invoice.buyer_name = 'New name'
        @invoice.save
        @invoice.errors.full_messages.should match_array([])
        @invoice.versions.size.should == 1
      end
    end
  end
end

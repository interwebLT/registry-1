require 'rails_helper'

RSpec.describe Message do
  subject(:message) { described_class.new }

  describe 'body validation', db: false do
    it 'rejects absent' do
      message.body = nil
      message.validate
      expect(message.errors).to be_added(:body, :blank)
    end
  end

  context 'with valid attributes' do
    before :all do
      @mssage = Fabricate(:message)
    end

    it 'should be valid' do
      @mssage.valid?
      @mssage.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @mssage = Fabricate(:message)
      @mssage.valid?
      @mssage.errors.full_messages.should match_array([])
    end

    it 'should have one version' do
      with_versioning do
        @mssage.versions.should == []
        @mssage.body = 'New body'
        @mssage.save
        @mssage.errors.full_messages.should match_array([])
        @mssage.versions.size.should == 1
      end
    end
  end
end

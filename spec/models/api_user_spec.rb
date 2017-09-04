require 'rails_helper'

RSpec.describe ApiUser do
  subject(:user) { described_class.new }

  describe 'registrar validation', db: false do
    it 'rejects absent' do
      user.registrar = nil
      user.validate
      expect(user.errors).to be_added(:registrar, :blank)
    end
  end

  describe 'username validation', db: false do
    it 'rejects absent' do
      user.username = nil
      user.validate
      expect(user.errors).to be_added(:username, :blank)
    end
  end

  describe 'password validation', db: false do
    it 'rejects absent' do
      user.password = nil
      user.validate
      expect(user.errors).to be_added(:password, :blank)
    end

    it 'rejects shorter than min length' do
      user.password = 'a' * (described_class.min_password_length - 1)
      user.validate
      expect(user.errors).to be_added(:password, :too_short,
                                      count: described_class.min_password_length)
    end
  end

  describe 'roles validation', db: false do
    it 'rejects absent' do
      user.roles = nil
      user.validate
      expect(user.errors).to be_added(:roles, :blank)
    end
  end

  context 'class methods' do
    before do
      Fabricate(:api_user, identity_code: '')
      Fabricate(:api_user, identity_code: 14212128025)
    end

    it 'should return all api users with given identity code' do
      ApiUser.all_by_identity_code('14212128025').size.should == 1
      ApiUser.all_by_identity_code(14212128025).size.should == 1
    end

    it 'should not return any api user with blank identity code' do
      ApiUser.all_by_identity_code('').size.should == 0
    end
  end

  it 'should be active by default' do
    api_user = described_class.new
    expect(api_user.active).to be true
  end

  context 'with valid attributes' do
    before :all do
      @api_user = Fabricate(:api_user)
    end

    it 'should have one version' do
      with_versioning do
        @api_user.versions.should == []
        @api_user.username = 'newusername'
        @api_user.save
        @api_user.errors.full_messages.should match_array([])
        @api_user.versions.size.should == 1
      end
    end
  end

  describe '::min_password_length', db: false do
    it 'returns minimum password length' do
      expect(described_class.min_password_length).to eq(6)
    end
  end
end

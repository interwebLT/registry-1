require 'rails_helper'

RSpec.describe Keyrelay do
  subject(:keyrelay) { described_class.new }

  before :example do
    Setting.ds_algorithm = 2
    Setting.ds_data_allowed = true
    Setting.ds_data_with_key_allowed = true
    Setting.key_data_allowed = true

    Setting.dnskeys_min_count = 0
    Setting.dnskeys_max_count = 9
    Setting.ns_min_count = 2
    Setting.ns_max_count = 11

    Setting.transfer_wait_time = 0

    Setting.admin_contacts_min_count = 1
    Setting.admin_contacts_max_count = 10
    Setting.tech_contacts_min_count = 0
    Setting.tech_contacts_max_count = 10

    Setting.client_side_status_editing_enabled = true

    Fabricate(:zone, origin: 'ee')
  end

  describe 'auth info pw validation' do
    it 'rejects absent' do
      keyrelay.auth_info_pw = nil
      keyrelay.validate
      expect(keyrelay.errors).to be_added(:auth_info_pw, :blank)
    end
  end

  describe 'domain validation' do
    it 'rejects absent' do
      keyrelay.domain = nil
      keyrelay.validate
      expect(keyrelay.errors).to be_added(:domain, :blank)
    end
  end

  describe 'key_data_public_key validation' do
    it 'rejects absent' do
      keyrelay.key_data_public_key = nil
      keyrelay.validate
      expect(keyrelay.errors).to be_added(:key_data_public_key, :blank)
    end
  end

  describe 'key_data_flags validation' do
    it 'rejects absent' do
      keyrelay.key_data_flags = nil
      keyrelay.validate
      expect(keyrelay.errors).to be_added(:key_data_flags, :blank)
    end
  end

  describe 'key_data_protocol validation' do
    it 'rejects absent' do
      keyrelay.key_data_protocol = nil
      keyrelay.validate
      expect(keyrelay.errors).to be_added(:key_data_protocol, :blank)
    end
  end

  describe 'key_data_alg validation' do
    it 'rejects absent' do
      keyrelay.key_data_alg = nil
      keyrelay.validate
      expect(keyrelay.errors).to be_added(:key_data_alg, :blank)
    end
  end

  context 'with valid attributes' do
    before :example do
      @keyrelay = Fabricate(:keyrelay)
    end

    it 'should be valid' do
      @keyrelay.valid?
      @keyrelay.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @keyrelay = Fabricate(:keyrelay)
      @keyrelay.valid?
      @keyrelay.errors.full_messages.should match_array([])
    end

    it 'should have one version' do
      with_versioning do
        @keyrelay.versions.should == []
        @keyrelay.auth_info_pw = 'newpw'
        @keyrelay.save
        @keyrelay.errors.full_messages.should match_array([])
        @keyrelay.versions.size.should == 1
      end
    end

    it 'is in pending status' do
      @keyrelay.status.should == 'pending'
    end
  end

  it 'is in expired status' do
    kr = Fabricate(:keyrelay, pa_date: Time.zone.now - 2.weeks)
    expect(kr.status).to eq('expired')
  end

  it 'does not accept invalid relative expiry' do
    kr = Fabricate.build(:keyrelay, expiry_relative: 'adf')
    expect(kr.save).to eq(false)
    expect(kr.errors[:expiry_relative].first).to eq('Expiry relative must be compatible to ISO 8601')
  end
end

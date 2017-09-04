require 'rails_helper'

RSpec.describe RegistrantVerification do
  subject(:verification) { described_class.new }

  describe 'domain name validation', db: false do
    it 'rejects absent' do
      verification.domain_name = nil
      verification.validate
      expect(verification.errors).to be_added(:domain_name, :blank)
    end
  end

  describe 'verification token validation', db: false do
    it 'rejects absent' do
      verification.verification_token = nil
      verification.validate
      expect(verification.errors).to be_added(:verification_token, :blank)
    end
  end

  describe 'action validation', db: false do
    it 'rejects absent' do
      verification.action = nil
      verification.validate
      expect(verification.errors).to be_added(:action, :blank)
    end
  end

  describe 'action type validation', db: false do
    it 'rejects absent' do
      verification.action_type = nil
      verification.validate
      expect(verification.errors).to be_added(:action_type, :blank)
    end
  end

  describe 'domain validation', db: false do
    it 'rejects absent' do
      verification.domain = nil
      verification.validate
      expect(verification.errors).to be_added(:domain, :blank)
    end
  end

  context 'with valid attributes' do
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

      @registrant_verification = Fabricate(:registrant_verification)
    end

    it 'should be valid' do
      @registrant_verification.valid?
      @registrant_verification.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @registrant_verification = Fabricate(:registrant_verification)
      @registrant_verification.valid?
      @registrant_verification.errors.full_messages.should match_array([])
    end
  end
end

require 'rails_helper'

describe 'EPP Helper', epp: true do
  context 'in context of Domain' do
    it 'generates valid create xml' do
      expected = Nokogiri::XML('<?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
          <command>
            <create>
              <domain:create
               xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
                <domain:name>example.ee</domain:name>
                <domain:period unit="y">1</domain:period>
                <domain:ns>
                  <domain:hostObj>ns1.example.net</domain:hostObj>
                  <domain:hostObj>ns2.example.net</domain:hostObj>
                </domain:ns>
                <domain:registrant>jd1234</domain:registrant>
                <domain:contact type="admin">sh8013</domain:contact>
                <domain:contact type="tech">sh8013</domain:contact>
                <domain:contact type="tech">sh801333</domain:contact>
                <domain:authInfo>
                  <domain:pw>2fooBAR</domain:pw>
                </domain:authInfo>
              </domain:create>
            </create>
            <clTRID>ABC-12345</clTRID>
          </command>
        </epp>
      ').to_s.squish

      generated = Nokogiri::XML(domain_create_xml).to_s.squish
      expect(generated).to eq(expected)

      ###

      expected = Nokogiri::XML('<?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
          <command>
            <create>
              <domain:create
               xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
                <domain:name>one.ee</domain:name>
                <domain:period unit="d">345</domain:period>
                <domain:ns>
                  <domain:hostObj>ns1.test.net</domain:hostObj>
                  <domain:hostObj>ns2.test.net</domain:hostObj>
                </domain:ns>
                <domain:registrant>32fsdaf</domain:registrant>
                <domain:contact type="admin">2323rafaf</domain:contact>
                <domain:contact type="tech">3dgxx</domain:contact>
                <domain:contact type="tech">345xxv</domain:contact>
                <domain:authInfo>
                  <domain:pw>sdgdgd4esfsa</domain:pw>
                </domain:authInfo>
              </domain:create>
            </create>
            <clTRID>ABC-12345</clTRID>
          </command>
        </epp>
      ').to_s.squish

      xml = domain_create_xml(
        name: 'one.ee',
        period_value: '345',
        period_unit: 'd',
        nameservers: [{hostObj: 'ns1.test.net'}, {hostObj: 'ns2.test.net'}],
        registrant: '32fsdaf',
        contacts: [
          {contact_value: '2323rafaf', contact_type: 'admin'},
          {contact_value: '3dgxx', contact_type: 'tech'},
          {contact_value: '345xxv', contact_type: 'tech'}
        ],
        pw: 'sdgdgd4esfsa'
      )

      generated = Nokogiri::XML(xml).to_s.squish
      expect(generated).to eq(expected)

      ###

      expected = Nokogiri::XML('<?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
          <command>
            <create>
              <domain:create
               xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
                <domain:name>one.ee</domain:name>
              </domain:create>
            </create>
            <clTRID>ABC-12345</clTRID>
          </command>
        </epp>
      ').to_s.squish

      xml = domain_create_xml(
        name: 'one.ee',
        period: false,
        nameservers: [],
        registrant: false,
        contacts: [],
        authInfo: false
      )

      generated = Nokogiri::XML(xml).to_s.squish
      expect(generated).to eq(expected)
    end
  end
end

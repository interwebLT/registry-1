module Epp
  def read_body filename
    File.read("spec/epp/requests/#{filename}")
  end

  # handles connection and login automatically
  def epp_request(data)
    begin
      parse_response(server.request(read_body(filename)))
    rescue Exception => e
      e
    end
  end

  def epp_plain_request filename
    begin
      parse_response(server.send_request(read_body(filename)))
    rescue Exception => e
      e
    end
  end

  def parse_response raw
    res = Nokogiri::XML(raw)

    obj = {
      results: [],
      clTRID: res.css('epp trID clTRID').text,
      parsed: res.remove_namespaces!,
      raw: raw
    }

    res.css('epp response result').each do |x|
      obj[:results] << {result_code: x[:code], msg: x.css('msg').text, value: x.css('value > *').try(:first).try(:text)}
    end

    obj[:result_code] = obj[:results][0][:result_code]
    obj[:msg] = obj[:results][0][:msg]

    obj
  end

  ### REQUEST TEMPLATES ###

  # THIS FEATURE IS EXPERIMENTAL AND NOT IN USE ATM

  def domain_create_template(xml_params={})
    xml_params[:nameservers] = xml_params[:ns] || [{hostObj: 'ns1.example.net'}, {hostObj: 'ns2.example.net'}]
    xml_params[:contacts] = xml_params[:contacts] || [
      {contact_value: 'sh8013', contact_type: 'admin'},
      {contact_value: 'sh8013', contact_type: 'tech'},
      {contact_value: 'sh801333', contact_type: 'tech'}
    ]

    # {hostAttr: {hostName: 'ns1.example.net', hostAddr_value: '192.0.2.2', hostAddr_ip}}

    xml = Builder::XmlMarkup.new

    xml.instruct!(:xml, :standalone => 'no')
    xml.epp('xmlns' => 'urn:ietf:params:xml:ns:epp-1.0') do
      xml.command do
        xml.create do
          xml.tag!('domain:create', 'xmlns:domain' => 'urn:ietf:params:xml:ns:domain-1.0') do

            xml.tag!('domain:name', (xml_params[:name] || 'expample.ee'))

            xml.tag!('domain:period', (xml_params[:period_value] || 1), 'unit' => (xml_params[:period_unit] || 'y'))

            xml.tag!('domain:ns') do
              xml_params[:nameservers].each do |x|
                xml.tag!('domain:hostObj', x[:hostObj])
              end
            end

            xml.tag!('domain:registrant', (xml_params[:registrant] || 'jd1234'))

            xml_params[:contacts].each do |x|
              xml.tag!('domain:contact', x[:contact_value], 'type' => (x[:contact_type]))
            end

            xml.tag!('domain:authInfo') do
              xml.tag!('domain:pw', xml_params[:pw] || '2fooBAR')
            end
          end
        end
        xml.clTRID 'ABC-12345'
      end
    end
  end
end

RSpec.configure do |c|
  c.include Epp, epp: true
end

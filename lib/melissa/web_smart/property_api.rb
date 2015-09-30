require 'melissa/web_smart/xml'

require 'rest-client'
require 'nokogiri'

module Melissa
  module WebSmart
    class PropertyAPI
      def property(fips, apn) 
        resp = RestClient.get('https://property.melissadata.net/v3/REST/Service.svc/doLookup',
                              { params: { id: ENV['MELISSA_DATA_WEB_SMART_ID'],
                                          fips: fips,
                                          apn: apn } })
        PropertyXMLParser.new(Nokogiri::XML(resp)).parse
      end
    end
  end
end

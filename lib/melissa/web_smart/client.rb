require 'melissa/web_smart/property_api'

module Melissa
  module WebSmart
    class Client
      def property(fips, apn)
        Melissa::WebSmart::PropertyAPI.new.property(fips, apn)
      end
    end
  end
end

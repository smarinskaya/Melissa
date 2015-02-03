require 'active_support/all' #TODO I can narrow down this

module Melissa
  class AddrObj
    AddressStruct = Struct.new(:number, :pre_directional, :name, :suffix, :post_directional)

    @@melissa_attributes = %w(
    Company
    LastName
    Address
    Address2
    Suite
    City
    CityAbbreviation
    State
    Zip
    Plus4
    CarrierRoute
    DeliveryPointCode
    DeliveryPointCheckDigit
    CountyFips
    CountyName
    AddressTypeCode
    AddressTypeString
    Urbanization
    CongressionalDistrict
    LACS
    LACSLinkIndicator
    RBDI
    PrivateMailbox
    TimeZoneCode
    TimeZone
    Msa
    Pmsa
    DefaultFlagIndicator
    SuiteStatus
    EWSFlag
    CMRA
    DsfNoStats
    DsfVacant
    CountryCode
    ZipType
    FalseTable
    DPVFootnotes
    LACSLinkReturnCode
    SuiteLinkReturnCode
    ELotNumber
    ELotOrder
  )

    # See http://www.melissadata.com/lookups/resultcodes.asp
    @@good_codes = ['AS01', 'AS02']
    @@bad_codes = ['AC02', 'AC03']

    def delivery_point
      "#{zip}#{plus4}#{delivery_point_code}"
    end

    def time_zone_offset
      GeoPoint.time_zone_offset(self.time_zone_code, self.state)
    end

    def address_struct
      @address_struct = begin
        if valid?
          if address_type_string == 'Street' || address_type_string == 'Highrise'
            match = self.address.match /^(\S+)\s?(N|NE|E|SE|S|SW|W|NW|) (\S.*?)\s?(N|NE|E|SE|S|SW|W|NW|)$/
          end
        elsif self.address
          match = self.address.match /^(\d\S*)\s?(N|NE|E|SE|S|SW|W|NW|) (\S.*?)\s?(N|NE|E|SE|S|SW|W|NW|)$/
        end
        if match
          # Parse out the optional suffix
          street_match = match[3].match /(\S.*?)( [A-Za-z]{2,4}|)$/
          if street_match
            name, suffix = street_match[1], street_match[2].strip
          else
            name, suffix = match[3], ''
          end
          AddressStruct.new(match[1], match[2], name, suffix, match[4])
        elsif self.address
          AddressStruct.new('', '', self.address, '', '')
        else
          AddressStruct.new
        end
      end
    end
  end
end


#a = Melissa::AddrObj.new(:address => 'valid street', :city => 'Tampa', :state => 'FL', :zip => '33626')
#puts "addr=#{a.address}"
#puts "deliverypoint=#{a.delivery_point}"

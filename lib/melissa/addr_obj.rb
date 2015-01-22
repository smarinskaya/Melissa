require 'active_support/all' #TODO I can narrow down this
require "melissa/config"

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

    # Fake out Melissa data in Dev and Test environments. For local tests, and for Release and Hotfix
    if Melissa.config.mode == :mock
      # Since we're faking it, create accessors that just return the corresponding opts value except the ones we dummy in the ctor
      @@melissa_attributes.each do |name|
        name = name.underscore
        class_eval <<-EOS
        define_method(:#{name}) do
          @#{name} ||= (@opts[:#{name}] || nil)
        end
        EOS
      end

      #Mock
      def initialize(opts)
        @opts = opts
        #@urbanization        = opts[:urbanization] || ''
        @resultcodes = ['AS01']
        @address_type_string = 'Street'
      end

      def delivery_point

        #getinng delivery_point based on address attributes from valid_addresses.csv file
        return MockValidator.get_delivery_point(self.address, self.suite, self.city, self.state, self.zip)
      end

      def valid?
        #returns true, only if we have the record with matching attributes in valid_addresses.csv file
        return MockValidator.valid?(self.address, self.suite, self.city, self.state, self.zip)
      end

      #### End of fake stuff ####

    else
      require 'ffi'
      extend FFI::Library

      ffi_lib Melissa.config.path_to_addr_obj_library if defined?(FFI)

      attr_functions = @@melissa_attributes.map { |name| ["mdAddrGet#{name}".to_sym, [:pointer], :string] }

      functions = attr_functions + [
          # method # parameters        # return
          [:mdAddrCreate, [], :pointer],
          [:mdAddrSetLicenseString, [:pointer, :string], :int],
          [:mdAddrSetPathToUSFiles, [:pointer, :string], :void],
          [:mdAddrInitializeDataFiles, [:pointer], :int],
          [:mdAddrClearProperties, [:pointer], :void],
          [:mdAddrSetCompany, [:pointer, :string], :void],
          [:mdAddrSetAddress, [:pointer, :string], :void],
          [:mdAddrSetAddress2, [:pointer, :string], :void],
          [:mdAddrSetSuite, [:pointer, :string], :void],
          [:mdAddrSetCity, [:pointer, :string], :void],
          [:mdAddrSetState, [:pointer, :string], :void],
          [:mdAddrSetZip, [:pointer, :string], :void],
          [:mdAddrSetUrbanization, [:pointer, :string], :void],
          [:mdAddrSetCountryCode, [:pointer, :string], :void],
          [:mdAddrVerifyAddress, [:pointer], :int],
          [:mdAddrGetResults, [:pointer], :string],
          [:mdAddrDestroy, [:pointer], :void],
          [:mdAddrGetLicenseExpirationDate, [:pointer], :string],
          [:mdAddrGetExpirationDate, [:pointer], :string],
      ]

      functions.each do |func|
        begin
          attach_function(*func)
        rescue Object => e
          raise "Could not attach #{func}, #{e.message}"
        end
      end

      attr_reader *@@melissa_attributes.map { |name| name.underscore.to_sym }

      # Get all the attributes out up-front so we can destroy the h_addr_lib object
      class_eval <<-EOS
      define_method(:fill_attributes) do |h_addr_lib|
        #{@@melissa_attributes.map { |name| "@#{name.underscore} = mdAddrGet#{name}(h_addr_lib)" }.join("\n")}
      end
      EOS

      def self.with_mdaddr
        h_addr_lib = mdAddrCreate
        mdAddrSetLicenseString(h_addr_lib, Melissa.config.addr_obj_license)
        mdAddrSetPathToUSFiles(h_addr_lib, Melissa.config.path_to_data_files)
        mdAddrInitializeDataFiles(h_addr_lib)
        yield h_addr_lib
      ensure
        mdAddrDestroy(h_addr_lib)
      end

      def self.license_expiration_date
        with_mdaddr { |h_addr_lib| mdAddrGetLicenseExpirationDate(h_addr_lib) }
      end

      def self.days_until_license_expiration
        #I compare Date objects. I think it is more accurate.
        #self.license_expiration_date returns string in format: "YYYY-MM-DD"
        (Date.parse(self.license_expiration_date) - Date.today).to_i
      end

      def self.expiration_date
        with_mdaddr { |h_addr_lib| mdAddrGetExpirationDate(h_addr_lib) }
      end

      def initialize(opts)
        h_addr_lib = mdAddrCreate
        mdAddrSetLicenseString(h_addr_lib, Melissa.config.addr_obj_license)
        mdAddrSetPathToUSFiles(h_addr_lib, Melissa.config.path_to_data_files)
        mdAddrInitializeDataFiles(h_addr_lib);
        # clear any properties from a previous call
        mdAddrClearProperties(h_addr_lib)

        mdAddrSetCompany(h_addr_lib, opts[:company] || '');
        mdAddrSetAddress(h_addr_lib, opts[:address] || '');
        mdAddrSetAddress2(h_addr_lib, opts[:address2] || '');
        mdAddrSetSuite(h_addr_lib, opts[:suite] || '');
        mdAddrSetCity(h_addr_lib, opts[:city] || '');
        mdAddrSetState(h_addr_lib, opts[:state] || '');
        mdAddrSetZip(h_addr_lib, opts[:zip] || '');
        mdAddrSetUrbanization(h_addr_lib, opts[:urbanization] || '');
        mdAddrSetCountryCode(h_addr_lib, opts[:country_code] || '');
        mdAddrVerifyAddress(h_addr_lib);

        @resultcodes = mdAddrGetResults(h_addr_lib).split(',')
        fill_attributes(h_addr_lib)

        mdAddrDestroy(h_addr_lib)
      end

      def valid?
        # Make sure there is at least 1 good code and no bad codes
        (@resultcodes & @@good_codes).present? && (@resultcodes & @@bad_codes).empty?
      end

      def delivery_point
        "#{zip}#{plus4}#{delivery_point_code}"
      end
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

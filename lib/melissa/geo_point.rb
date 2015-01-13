require 'ffi'

module Melissa
  class GeoPoint
    extend FFI::Library

    @@license = 'valid_license_key'

    @@melissa_attributes = %w(
    Latitude
    Longitude
    CensusTract
    CensusBlock
    CountyFips
    CountyName
    PlaceCode
    PlaceName
    TimeZoneCode
    TimeZone
    CBSACode
    CBSATitle
    CBSALevel
    CBSADivisionCode
    CBSADivisionTitle
    CBSADivisionLevel
  )

    @@codes = {
        'GS01' => 'Record was coded to the ZIP + 4 centroid (U.S.) or or the full 6-digit Postal Code level (Canada).',
        'GS02' => 'Record was coded to the ZIP + 2 centroid.',
        'GS03' => 'Record was coded to the 5-digit ZIP Code centroid (U.S.) or or the first 3-digit Postal Code level (Canada).',
        'GS05' => 'Record was coded to rooftop level.(Available On-Premise only)',
        'GS06' => 'Record was coded to interpolated rooftop level.(Available On-Premise only)*',
        'GE01' => 'ZIP Code Error. An invalid ZIP Code was entered.',
        'GE02' => 'ZIP Code not found. The submitted ZIP Code was not found in the database.',
        'GE03' => 'Demo Mode. GeoCoder Object is in Demo Mode and a ZIP Code outside the demo range was detected.',
        'GE04' => 'The GeoCoder Object data files are expired. Please update with the latest data files.',
        'GE05' => 'Geocoding for the country of input record is disabled for your license. Please contact your sales representative to enable.',
    }

    # See http://www.melissadata.com/lookups/resultcodes.asp
    @@good_codes = ['GS01', 'GS02', 'GS03', 'GS05', 'GS06']
    #@@bad_codes   = ['GE01', 'GE02']
    @@fatal_codes = ['GE03', 'GE04', 'GE05']

    @@time_zones = {
        '04' => 'Atlantic/Bermuda',
        '05' => 'US/Eastern',
        '06' => 'US/Central',
        '07' => 'US/Mountain',
        '08' => 'US/Pacific',
        '09' => 'US/Alaska',
        '10' => 'US/Hawaii',
        '11' => 'US/Samoa',
        '13' => 'Pacific/Majuro',
        '14' => 'Pacific/Guam',
        '15' => 'Pacific/Palau'
    }

    begin
      ffi_lib '/opt/dqs/GeoObj/libmdGeo.so'

      attr_functions = @@melissa_attributes.map { |name| ["mdGeoGet#{name}".to_sym, [:pointer], :string] }

      functions = attr_functions + [
          # method # parameters        # return
          [:mdGeoCreate, [], :pointer],
          [:mdGeoSetLicenseString, [:pointer, :string], :int],
          [:mdGeoSetPathToGeoCodeDataFiles, [:pointer, :string], :void],
          [:mdGeoSetPathToGeoPointDataFiles, [:pointer, :string], :void],
          [:mdGeoInitializeDataFiles, [:pointer], :int],
          [:mdGeoGeoPoint, [:pointer, :string, :string, :string], :int],
          [:mdGeoGetResults, [:pointer], :string],
          [:mdGeoDestroy, [:pointer], :void],
          [:mdGeoGetLicenseExpirationDate, [:pointer], :string],
          [:mdGeoGetExpirationDate, [:pointer], :string],
      ]

      functions.each do |func|
        begin
          attach_function(*func)
        rescue Object => e
          raise "Could not attach #{func}, #{e.message}"
        end
      end

      attr_reader *@@melissa_attributes.map { |name| name.underscore.to_sym }

      # Get all the attributes out up-front so we can destroy the mdGeo object
      class_eval <<-EOS
      define_method(:fill_attributes) do |mdGeo|
        #{@@melissa_attributes.map { |name| "@#{name.underscore} = mdGeoGet#{name}(mdGeo)" }.join("\n")}
      end
      EOS

      def self.with_mdgeo
        mdGeo = mdGeoCreate
        mdGeoSetLicenseString(mdGeo, @@license)
        mdGeoSetPathToGeoCodeDataFiles(mdGeo, "/opt/dqs/data")
        mdGeoSetPathToGeoPointDataFiles(mdGeo, "/opt/dqs/data")
        result = mdGeoInitializeDataFiles(mdGeo)
        if result != 0
          raise mdGeoGetInitializeErrorString(mdGeo)
        end
        yield mdGeo
      ensure
        mdGeoDestroy(mdGeo) if mdGeo
      end

      def self.license_expiration_date
        with_mdgeo { |mdGeo| mdGeoGetLicenseExpirationDate(mdGeo) }
      end

      def self.expiration_date
        with_mdgeo { |mdGeo| mdGeoGetExpirationDate(mdGeo) }
      end

      def initialize(addr_obj_or_inquiry)
        @is_valid = false
        if addr_obj_or_inquiry.kind_of?(Inquiry)
          @addr_obj = AddrObj.create_from_inquiry(addr_obj_or_inquiry)
        elsif addr_obj_or_inquiry.kind_of?(AddrObj)
          @addr_obj = addr_obj_or_inquiry
        else
          raise "Invalid call to GeoPoint, unknown object #{addr_obj_or_inquiry.inspect}"
        end
        mdGeo = mdGeoCreate
        mdGeoSetLicenseString(mdGeo, @@license)
        mdGeoSetPathToGeoCodeDataFiles(mdGeo, "/opt/dqs/data")
        mdGeoSetPathToGeoPointDataFiles(mdGeo, "/opt/dqs/data")
        result = mdGeoInitializeDataFiles(mdGeo)
        if result != 0
          # TODO: Error condition
          error_message = mdGeoGetInitializeErrorString(mdGeo)
        end

        result = mdGeoGeoPoint(mdGeo, @addr_obj.zip || '', @addr_obj.plus4 || '', @addr_obj.delivery_point_code || '')

        @resultcodes = mdGeoGetResults(mdGeo).split(',')
        fatals = @resultcodes & @@fatal_codes
        @is_valid = fatals.blank?
        if @is_valid
          fill_attributes(mdGeo)
          # Convert from strings to actual types
          if @latitude.blank?
            @latitude = nil
          else
            @latitude = @latitude.to_f
          end
          if @longitude.blank?
            @longitude = nil
          else
            @longitude = @longitude.to_f
          end
          if @latitude == 0.0 && @longitude == 0.0
            @latitude = nil
            @longitude = nil
            @is_valid = false
          end
        else
          fatals.each do |fatal_code|
            Rails.logger.error("FATAL ERROR Melissa GeoPoint returned #{fatal_code}-#{@@codes[fatal_code]}")
          end
        end

      ensure
        mdGeoDestroy(mdGeo) if mdGeo
      end
    rescue LoadError => e
      raise if Rails.env.production?

      Rails.logger.debug("Could not find geolib, gonna fake it")

      #### Start of fake stuff ####

      # Since we're faking it, create accessors that just return the corresponding opts value except the ones we dummy in the ctor
      @@melissa_attributes.each do |name|
        name = name.underscore
        class_eval <<-EOS
        define_method(:#{name}) do
          @#{name} ||= (@opts[:#{name}] || '')
        end
        EOS
      end

      def initialize(addr_obj_or_inquiry)
        @is_valid = false
        if addr_obj_or_inquiry.kind_of?(Inquiry)
          @addr_obj = AddrObj.create_from_inquiry(addr_obj_or_inquiry)
        elsif addr_obj_or_inquiry.kind_of?(AddrObj)
          @addr_obj = addr_obj_or_inquiry
        else
          raise "Invalid call to GeoPoint, unknown object #{addr_obj_or_inquiry.inspect}"
        end
        @latitude = 27.850397
        @longitude = -82.659555
        @time_zone_code = '05'
        @resultcodes = ['GS05']
        @is_valid = true
      end

      #### End of fake stuff ####

    end

    def valid?
      # Make sure there is at least 1 good code
      @is_valid
    end

    def time_zone_offset
      GeoPoint.time_zone_offset(self.time_zone_code, @addr_obj.state)
    end

    # Hack for AddrObj to share code
    def self.time_zone_offset(time_zone_code, state=nil)
      time_zone = @@time_zones[time_zone_code]
      return nil unless time_zone
      time_zone = 'US/Arizona' if state == 'AZ'
      return Time.now.in_time_zone(time_zone).utc_offset / -60
    end
  end
end

#a = AddrObj.new(:address => 'valid street', :city => 'Tampa', :state => 'FL', :zip => '33626')
#g = GeoPoint.new(a)
#puts "lat,long=#{g.latitude},#{g.longitude}"

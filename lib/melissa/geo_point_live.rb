require 'ffi'

module Melissa
  class GeoPointLive < GeoPoint

    def self.lib_loaded?
      return @lib_loaded if defined?(@lib_loaded)
      extend FFI::Library

      ffi_lib Melissa.config.geo_point_lib
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
    rescue LoadError => e
      puts "WARNING: #{Melissa.config.geo_point_lib} could not be loaded"
      return @lib_loaded = false
    else
      return @lib_loaded = true
    end

    def self.with_mdgeo
      raise "Unable to load melissa library #{Melissa.config.addr_obj_lib}" unless self.lib_loaded?
      raise "Unable to find the license for Melissa Data library #{Melissa.config.license}" unless Melissa.config.license.present?
      raise "Unable to find data files for Melissa Data library #{Melissa.config.data_path}" unless Melissa.config.data_path.present?
      begin
        mdGeo = mdGeoCreate
        mdGeoSetLicenseString(mdGeo, Melissa.config.license)
        mdGeoSetPathToGeoCodeDataFiles(mdGeo, Melissa.config.data_path)
        mdGeoSetPathToGeoPointDataFiles(mdGeo, Melissa.config.data_path)
        result = mdGeoInitializeDataFiles(mdGeo)
        if result != 0
          raise mdGeoGetInitializeErrorString(mdGeo)
        end
        yield mdGeo
      ensure
        mdGeoDestroy(mdGeo) if mdGeo
      end
    end

    #This function returns a date value corresponding to the date when the current license
    #string expires.
    def self.license_expiration_date
      Date.parse(with_mdgeo { |mdGeo| mdGeoGetLicenseExpirationDate(mdGeo) })
    end

    def self.days_until_license_expiration
      #I compare Date objects. I think it is more accurate.
      #self.license_expiration_date returns string in format: "YYYY-MM-DD"
      (self.license_expiration_date - Date.today).to_i
    end

    # his function returns a date value representing the
    # date when the current data files expire. This date enables you to confirm that the
    # data files you are using are the latest available.
    def self.expiration_date
      Date.parse(with_mdgeo { |mdGeo| mdGeoGetExpirationDate(mdGeo)})
    end

    def self.days_until_data_expiration
      #I compare Date objects. I think it is more accurate.
      #self.license_expiration_date returns string in format: "YYYY-MM-DD"
      (self.expiration_date - Date.today).to_i
    end

    def initialize(opts)
      @is_valid = false

      self.class.with_mdgeo do |mdGeo|
        if opts.kind_of?(AddrObj)
          mdGeoGeoPoint(mdGeo, opts.zip || '', opts.plus4 || '', opts.delivery_point_code || '')
        elsif opts.kind_of?(Hash)
          mdGeoGeoPoint(mdGeo, opts[:zip] || '', opts[:plus4] || '', opts[:delivery_point_code] || '')
        else
          raise "Invalid call to GeoPoint, unknown object #{opts.inspect}"
        end
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
            raise "FATAL ERROR Melissa GeoPoint returned #{fatal_code}-#{@@codes[fatal_code]}"
          end
        end
      end

      @@callbacks.each do |callback|
        callback.call
      end
    end
  end
end

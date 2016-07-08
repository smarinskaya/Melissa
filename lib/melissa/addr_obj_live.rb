require 'ffi'
require 'sync_attr'

module Melissa
  class AddrObjLive < AddrObj

    sync_cattr_reader :lib_loaded do
      begin
        extend FFI::Library

        ffi_lib Melissa.config.addr_obj_lib
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
      rescue LoadError => e
        puts "WARNING: #{Melissa.config.addr_obj_lib} could not be loaded"
        false
      else
        true
      end
    end

    def self.with_mdaddr
      raise "Unable to load melissa library #{Melissa.config.addr_obj_lib}" unless lib_loaded
      raise "Unable to find the license for Melissa Data library #{Melissa.config.license}" unless Melissa.config.license.present?
      raise "Unable to find data files for Melissa Data library #{Melissa.config.data_path}" unless Melissa.config.data_path.present?
      begin
        h_addr_lib = mdAddrCreate
        mdAddrSetLicenseString(h_addr_lib, Melissa.config.license)
        mdAddrSetPathToUSFiles(h_addr_lib, Melissa.config.data_path)
        mdAddrInitializeDataFiles(h_addr_lib)
        yield h_addr_lib
      ensure
        mdAddrDestroy(h_addr_lib) if h_addr_lib
      end
    end

    #This function returns a date value corresponding to the date when the current license
    #string expires.

    def self.license_expiration_date
      Date.parse(with_mdaddr { |h_addr_lib| mdAddrGetLicenseExpirationDate(h_addr_lib) })
    end

    def self.days_until_license_expiration
      #I compare Date objects. I think it is more accurate.
      #self.license_expiration_date returns string in format: "YYYY-MM-DD"
      (self.license_expiration_date - Date.today).to_i
    end

    # U.S. Only — This function returns a date value representing the
    # date when the current U.S. data files expire. This date enables you to confirm that the
    # data files you are using are the latest available.

    def self.data_expiration_date
      Date.strptime(with_mdaddr { |h_addr_lib| mdAddrGetExpirationDate(h_addr_lib) }, '%m-%d-%Y')
    end

    def self.days_until_data_expiration
      (self.data_expiration_date - Date.today).to_i
    end

    def initialize(opts)
      self.class.with_mdaddr do |h_addr_lib|
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
      end
      @@callbacks.each do |callback|
        callback.call
      end
    end

    def valid?
      # Make sure there is at least 1 good code and no bad codes
      (@resultcodes & @@good_codes).present? && (@resultcodes & @@bad_codes).empty?
    end
  end
end

require 'ffi'

module Melissa
  class AddrObjLive < AddrObj
    begin
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
        puts "In live mode"
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
    rescue LoadError => e
      puts "Melissa AddrObj library was not loaded!"
    else
      Melissa.config.addr_obj_library_loaded = true
    end
  end
end
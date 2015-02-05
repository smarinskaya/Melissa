require 'yaml'

module Melissa

  MODES = [:mock, :live]

  class Config

    attr_accessor :mode, :addr_obj_license, :path_to_data_files, :path_to_addr_obj_library, :addr_obj_library_loaded
    attr_accessor :geo_point_license, :path_to_geo_point_library, :geo_point_library_loaded

    def initialize
      #default values
      #TODO will this flag be set at this point??
      #TODO do we need separate checks for 2 libraries?
      #TODO do we need separate mock/live mode for 2 libraries?

      puts "In Config#initialize #{@addr_obj_library_loaded.present?}"
      if @addr_obj_library_loaded.present? && (@addr_obj_library_loaded == true)
        @mode = :live
      else
        @mode = :mock
      end

      #It is recommended to read the following config options from environment variables
      #From Melissa Data documentation:
      #The license string should be entered as an environment variable named
      #MD_LICENSE. This allows you to update your license string without editing
      #and recompiling your code

      @addr_obj_license         = ENV['MELISSA_ADDRESS_OBJECT_LICENSE']
      @path_to_data_files       = ENV['MELISSA_ADDRESS_OBJECT_DATA_FILES']
      @path_to_addr_obj_library = ENV['']

      @geo_point_license         = ENV['MELISSA_GEO_POINT_LICENSE']
      #TODO is it different from AddrObj
      @path_to_data_files       = ENV['']
      @path_to_geo_point_library = ENV['']
    end

    #you can set config values from your code using:
    #   Melissa.configure do |config|
    #     config.load_from_yml("My new path to yml file")
    #   end

    def load_from_yml(path_to_yml)
      begin
        config_hash = YAML::load_file(path_to_yml)
      rescue Errno::ENOENT
        raise "YAML configuration file couldn't be found. We need #{path_to_yml}"
        return
      end

      #set attributes from yml
      #For AddrObj
      @addr_obj_license         = config_hash["AddrObj"][:license_key]
      @path_to_data_files       = config_hash["AddrObj"][:path_to_data_files]
      @path_to_addr_obj_library = config_hash["AddrObj"][:path_to_library]
      #For GeoPoint
      @geo_point_license         = config_hash["GeoPoint"][:license_key]
      @path_to_data_files        = config_hash["GeoPoint"][:path_to_data_files]
      @path_to_geo_point_library = config_hash["GeoPoint"][:path_to_library]
    end
  end
end
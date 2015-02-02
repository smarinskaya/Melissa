require 'yaml'

module Melissa

  MODES = [:mock, :live]

  class Config

    attr_accessor :mode, :addr_obj_license, :path_to_yaml, :path_to_data_files, :path_to_addr_obj_library
    attr_accessor :geo_point_license, :path_to_geo_point_library

    def initialize
      #default values
      @mode = :mock

      #you can configure @path_to_yaml from your code using:
      #   Melissa.configure do |config|
      #     config.path_to_yaml = "My new path to yaml file"
      #   end
      @path_to_yml = File.dirname(__FILE__)
      melissa_yaml = File.join(File.dirname(__FILE__),"../../config/melissa.yaml")

      begin
        config_hash = YAML::load_file(melissa_yaml)
      rescue Errno::ENOENT
        raise "YAML configuration file couldn't be found. We need #{melissa_yaml}"
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
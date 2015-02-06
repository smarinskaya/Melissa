require 'yaml'

module Melissa

  MODES = [:mock, :live]

  class Config

    attr_accessor :mode, :license, :data_path, :addr_obj_lib, :addr_obj_lib_loaded
    attr_accessor :geo_point_lib, :geo_point_lib_loaded

    def initialize
      #default values
      #TODO will this flag be set at this point??
      #TODO do we need separate checks for 2 libraries?
      #TODO do we need separate mock/live mode for 2 libraries?

      puts "In Config#initialize #{@addr_obj_library_loaded.inspect}"
      if defined?(@addr_obj_library_loaded) && @addr_obj_library_loaded
        @mode = :live
      else
        @mode = :mock
      end

      #It is recommended to read the following config options from environment variables
      #From Melissa Data documentation:
      #The license string should be entered as an environment variable named
      #MD_LICENSE. This allows you to update your license string without editing
      #and recompiling your code

      self.home          = ENV['MELISSA_HOME']          if ENV['MELISSA_HOME']
      @data_path         = ENV['MELISSA_DATA_PATH']     if ENV['MELISSA_DATA_PATH']
      @addr_obj_lib      = ENV['MELISSA_ADDR_OBJ_LIB']  if ENV['MELISSA_ADDR_OBJ_LIB']
      @geo_point_lib     = ENV['MELISSA_GEO_POINT_LIB'] if ENV['MELISSA_GEO_POINT_LIB']
      @license           = ENV['MD_LICENSE']
    end

    #you can configure path_to_yml from your code using:
    #   Melissa.configure do |config|
    #     config.yml_path = "/etc/config/melissa.yml"
    #   end
    def yml_path=(yml_path)
      config_hash = YAML::load_file(yml_path)
      config_hash.each do |key, value|
        send("#{key}=", value)
      end
    rescue Errno::ENOENT
      raise "YAML configuration file couldn't be found. We need #{melissa_yml}"
    end

    def home=(home)
      @addr_obj_lib = "#{home}/AddrObj/libmdAddr.so"
      @geo_obj_lib  = "#{home}/GeoObj/libmdGeo.so"
      @data_path    = "#{home}/data"
    end
  end
end

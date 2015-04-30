require 'yaml'

module Melissa

  MODES = [:mock, :live]

  class Config

    attr_accessor :mode, :license, :data_path, :addr_obj_lib, :geo_point_lib

    def initialize
      #It is recommended to read the following config options from environment variables
      #From Melissa Data documentation:
      #The license string should be entered as an environment variable named
      #MD_LICENSE. This allows you to update your license string without editing
      #and recompiling your code
      self.mode = :live

      self.home = ENV['MELISSA_HOME'] || '/usr/local/dqs'
      self.config_path = ENV['MELISSA_CONFIG_PATH'] if ENV['MELISSA_CONFIG_PATH']
      @data_path = ENV['MELISSA_DATA_PATH'] if ENV['MELISSA_DATA_PATH']
      @addr_obj_lib = ENV['MELISSA_ADDR_OBJ_LIB'] if ENV['MELISSA_ADDR_OBJ_LIB']
      @geo_point_lib = ENV['MELISSA_GEO_POINT_LIB'] if ENV['MELISSA_GEO_POINT_LIB']
      @license = ENV['MD_LICENSE'] if ENV['MD_LICENSE']
    end

    #you can configure config_path from your code using:
    #   Melissa.configure do |config|
    #     config.config_path = "/etc/config/melissa"
    #   end
    def config_path=(config_path)
      File.open(config_path, 'r') do |fin|
        fin.each do |line|
          line.strip!
          next if line.empty? || line[0] == '#'
          equal_index = line.index('=')
          key = line[0, equal_index].strip.downcase
          value = line[(equal_index+1)..-1].strip
          send("#{key}=", value)
        end
      end
    rescue Errno::ENOENT
      raise "Configuration file couldn't be found. We need #{config_path}"
    end

    def home=(home)
      @addr_obj_lib = "#{home}/AddrObj/libmdAddr.so"
      @geo_point_lib = "#{home}/GeoObj/libmdGeo.so"
      @data_path = "#{home}/data"
    end
  end
end

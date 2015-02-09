require 'yaml'

module Melissa

  MODES = [:mock, :live]

  class Config

    attr_accessor :mode, :license, :data_path, :addr_obj_lib, :addr_obj_lib_loaded
    attr_accessor :geo_point_lib, :geo_point_lib_loaded

    def initialize

      puts "In the beginning of Config#initialize:  @addr_obj_library_loaded: #{@addr_obj_library_loaded.inspect}"
      if defined?(@addr_obj_library_loaded) && @addr_obj_library_loaded
        @mode = :live
      else
        @mode = :mock
      end

      puts "In Config.new: #{@mode}"

      #It is recommended to read the following config options from environment variables
      #From Melissa Data documentation:
      #The license string should be entered as an environment variable named
      #MD_LICENSE. This allows you to update your license string without editing
      #and recompiling your code

      self.config_path   = ENV['MELISSA_CONFIG_PATH']   if ENV['MELISSA_CONFIG_PATH']
      self.home          = ENV['MELISSA_HOME']          if ENV['MELISSA_HOME']
      @data_path         = ENV['MELISSA_DATA_PATH']     if ENV['MELISSA_DATA_PATH']
      @addr_obj_lib      = ENV['MELISSA_ADDR_OBJ_LIB']  if ENV['MELISSA_ADDR_OBJ_LIB']
      @geo_point_lib     = ENV['MELISSA_GEO_POINT_LIB'] if ENV['MELISSA_GEO_POINT_LIB']
      @license           = ENV['MD_LICENSE']            if ENV['MD_LICENSE']
    end

    #you can configure yml_path from your code using:
    #   Melissa.configure do |config|
    #     config.config_path = "/etc/config/melissa.txt"
    #   end
    def config_path=(config_path)
      File.open(config_path, 'r') do |fin|
        fin.each do |line|
          line.strip!
          next if line.empty? || line[0] == '#'
          equal_index = line.index('=')
          key   = line[0,equal_index].strip.downcase
          value = line[(equal_index+1)..-1].strip
          send("#{key}=", value)
        end
      end
    rescue Errno::ENOENT
      raise "Configuration file couldn't be found. We need #{config_path}"
    end

    def home=(home)
      @addr_obj_lib = "#{home}/AddrObj/libmdAddr.so"
      @geo_obj_lib  = "#{home}/GeoObj/libmdGeo.so"
      @data_path    = "#{home}/data"
      puts "In home=, @addr_obj_lib=#{@addr_obj_lib}"
    end
  end
end

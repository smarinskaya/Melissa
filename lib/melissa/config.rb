require 'yaml'

module Melissa

  MODES = [:mock, :prod]

  class Config

    attr_accessor :mode, :addr_obj_license, :path_to_yaml

    def initialize
      #default values
      @mode = :mock

      #you can configure @path_to_yaml from your code using:
      #   Melissa.configure do |config|
      #     config.path_to_yaml = "My new path to yaml file"
      #   end
      @path_to_yml = File.dirname(__FILE__)
      melissa_yaml = File.join(File.dirname(__FILE__),"melissa.yaml")

      begin
        config_hash = YAML::load_file(melissa_yaml)
      rescue Errno::ENOENT
        #log(:warning, "YAML configuration file couldn't be found. Using defaults.");
        raise "YAML configuration file couldn't be found. We need #{melissa_yaml}"
        return
      end

      #set attributes from yml
      puts "config_hash: #{config_hash}"
      @addr_obj_license = config_hash["AddrObj"][:license_key]
    end
  end
end
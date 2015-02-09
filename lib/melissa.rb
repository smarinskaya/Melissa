

module Melissa
  # autoload :AddrObj,        'melissa/addr_obj'
  # autoload :AddrObjMock,    'melissa/addr_obj_mock'
  # autoload :AddrObjLive,    'melissa/addr_obj_live'
  # autoload :GeoPoint,       'melissa/geo_point'
  # autoload :GeoPointMock,    'melissa/geo_point_mock'
  # autoload :GeoPointLive,    'melissa/geo_point_live'

  class << self
    attr_writer :config
  end

  def self.addr_obj(attrs)
    puts "In Melissa#addr_obj checking mode: #{config.mode}"
    if config.mode == :live
      raise LoadError, "Melissa AddrObj was not loaded!" unless config.addr_obj_lib_loaded
      AddrObjLive.new(attrs)
    else
      AddrObjMock.new(attrs)
    end
  end

  def self.geo_point(attrs)
    if config.mode == :live
      raise LoadError, "Melissa GeoPoint object was not loaded!" unless config.geo_point_lib_loaded
      GeoPointLive.new(attrs)
    else
      GeoPointMock.new(attrs)
    end
  end

  def self.config
    @config ||= Config.new
  end

  def self.reset
    @config = Config.new
  end

  def self.configure
    yield(config)
  end
end

require 'melissa/railtie' if defined?(Rails)

require "melissa/version"
require "melissa/config"
require 'melissa/addr_obj'
require 'melissa/geo_point'
require 'melissa/addr_obj_live'
require 'melissa/geo_point_live'
require 'melissa/addr_obj_mock'
require 'melissa/geo_point_mock'

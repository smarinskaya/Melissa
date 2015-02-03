require "melissa/version"
require "melissa/config"

module Melissa
  autoload :AddrObj,        'melissa/addr_obj'
  autoload :AddrObjMock,    'melissa/addr_obj_mock'
  autoload :AddrObjLive,    'melissa/addr_obj_live'
  autoload :GeoPoint,       'melissa/geo_point'

  class << self
    attr_writer :config
  end

  def self.addr_obj(attrs)
    if config.mode == :live
      raise LoadError, "Melissa AddrObj was not loaded!" unless config.addr_obj_library_loaded
      AddrObjLive.new(attrs)
    else
      AddrObjMock.new(attrs)
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

#TODO Why do we need that line?
require 'melissa/railtie' if defined?(Rails)
module Melissa

  class << self
    attr_writer :config
  end

  def self.addr_obj(attrs)
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


#valid_address_obj = Melissa.adrr_obj(:address => 'valid street', :city => 'Tampa', :state => 'FL', :zip => '33626')
#puts "addr=#{valid_address_obj.address}"
#puts "deliverypoint=#{valid_address_obj.delivery_point}"

#g = Melissa.geo_point(valid_address_obj)
#puts "lat,long=#{g.latitude},#{g.longitude}"

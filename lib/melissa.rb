require "melissa/version"
require "melissa/config"

module Melissa
  autoload :AddrObj,    'melissa/addr_obj'
  autoload :GeoPoint,   'melissa/geo_point'

  class << self
    attr_writer :config
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
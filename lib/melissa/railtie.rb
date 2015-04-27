require 'yaml'
require 'erb'

module Melissa
  class Railtie < Rails::Railtie #:nodoc:
    # Make the Melissa config available in the Rails application config
    config.before_configuration do
      config_file = Rails.root.join('config', 'melissa.yml')
      if config_file.file?
        full_config = YAML.load(ERB.new(File.read(config_file)).result(binding))
        config_hash      = full_config[Rails.env]
        raise 'Invalid Melissa configuration' if config == nil

        config_hash.each do |key, value|
          value = value.to_sym if key == 'mode'
          send("Melissa.config.#{key}=", value)
        end
      end
    end
  end
end

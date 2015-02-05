module Melissa
  class Railtie < Rails::Railtie #:nodoc:
    # Make the Melissa config available in the Rails application config
    config.before_configuration do
      config_file = Rails.root.join('config', 'melissa.yml')
      if config_file.file?
        Melissa.config.load_from_yml(config_file)
      end
    end
  end
end
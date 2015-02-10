module Melissa
  class Railtie < Rails::Railtie #:nodoc:
    # Make the Melissa config available in the Rails application config
    config.before_configuration do
      config_file = Rails.root.join('config', 'melissa.txt')
      if config_file.file?
        Melissa.config.config_path = config_file
      end
    end
  end
end

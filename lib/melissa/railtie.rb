module Melissa
  class Railtie < Rails::Railtie #:nodoc:
    # Make the Melissa config available in the Rails application config
    config.before_configuration do
      yml_file = Rails.root.join('config', 'melissa.yml')
      if yml_file.file?
        ::Melissa.config.yml_file = yml_file
      end
    end
  end
end

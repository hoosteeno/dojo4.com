require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dojo4Com
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    require "#{ Rails.root }/lib/current.rb"
    require "#{ Rails.root }/lib/lorem.rb"
    require "#{ Rails.root }/lib/settings.rb"
    require "#{ Rails.root }/lib/slug.rb"
    require "#{ Rails.root }/lib/site.rb"
    require "#{ Rails.root }/lib/site/model.rb"
  end
end

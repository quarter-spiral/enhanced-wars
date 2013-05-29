require 'sprockets'
require 'sprockets-helpers'
require 'coffee_script'

module EnhancedWars
  class App < Sprockets::Environment
    def initialize
      super
      append_path File.expand_path('../../../game', __FILE__)

      this = self
      Sprockets::Helpers.configure do |config|
        config.environment = this
        config.prefix      = '/'
        config.digest      = true
        config.public_path = 'public'

        # Debug mode automatically sets
        # expand = true, digest = false, manifest = false
        config.debug       = true if ENV['RACK_ENV'] != 'production'
      end

      context_class.class_eval do
        include Sprockets::Helpers
      end
    end
  end
end
require 'sprockets'
require 'coffee_script'

module EnhancedWars
  class App < Sprockets::Environment
    def initialize
      super
      append_path File.expand_path('../../../game', __FILE__)
    end
  end
end
require 'bundler'
Bundler.require

if ENV['RACK_ENV'] == 'production' && ENV['QS_HTTP_AUTH_PASSWORD']
  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    password == ENV['QS_HTTP_AUTH_PASSWORD']
  end
end

class PathCorrector
  def initialize(app)
    @app = app
  end

  def call(env)
    env['PATH_INFO'] = '/index.html' if env['PATH_INFO'] == '/'
    @app.call(env)
  end
end

use PathCorrector
run EnhancedWars::App.new
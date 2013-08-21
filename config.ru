require 'bundler'
Bundler.require

if ENV['RACK_ENV'] == 'production' && ENV['QS_HTTP_AUTH_PASSWORD']
  # use Rack::Auth::Basic, "Restricted Area" do |username, password|
#     password == ENV['QS_HTTP_AUTH_PASSWORD']
#   end
end

if ENV['RACK_ENV'] == 'production'
  require 'rack/ssl'
  use Rack::SSL
end

require 'ping-middleware'

use Ping::Middleware

class IndexHtmlServer
  def initialize(app)
    @app = app
  end

  def call(env)
    env['PATH_INFO'] = '/index.html' if env['PATH_INFO'] == '/'
    @app.call(env)
  end
end
use IndexHtmlServer

class FallThroughStatic
  def initialize(app, options = {})
    @app = app
    @rack_static = Rack::Static.new(app, options)
  end

  def call(env)
    path = env["PATH_INFO"]
    if @rack_static.can_serve(path)
      status, header, body = @rack_static.call(env)
      return [status, header, body] if status.to_i != 404
    end

    @app.call(env)
  end
end
use FallThroughStatic, :urls => ["/app"], :root => "public/", :header_rules => [[:all, {'Cache-Control' => 'public, max-age=31536000'}]]

run EnhancedWars::App.new
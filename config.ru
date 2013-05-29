require 'bundler'
Bundler.require

if ENV['RACK_ENV'] == 'production' && ENV['QS_HTTP_AUTH_PASSWORD']
use Rack::Auth::Basic, "Restricted Area" do |username, password|
  password == ENV['QS_HTTP_AUTH_PASSWORD']
end

run EnhancedWars::App.new
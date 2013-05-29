require "bundler/gem_tasks"

import 'spec/javascripts/support/headless.rake'

require 'rake/sprocketstask'
require 'enhanced-wars'

Rake::SprocketsTask.new do |t|
  t.environment = EnhancedWars::App.new
  t.output      = "./public"
  t.assets      = %w(app/javascript/game.js app/stylesheet/game.css)
end

namespace :assets do
  task :precompile => ['assets'] do
  end
end
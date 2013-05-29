module EnhancedWars
  SpecsApp = Rack::Builder.new do
    map '/__specs__' do
      spec_app = Sprockets::Environment.new
      spec_app.append_path File.expand_path('../../', __FILE__)
      run spec_app
    end

    run EnhancedWars::App.new
  end
end
Bundler.setup

require 'thread'
require 'rack'
require 'thin'
require 'net/http'
require 'uri'
require 'json'
require 'enhanced-wars'
load File.expand_path('../specs_app.rb', __FILE__)

def find_available_port
  server = TCPServer.new('127.0.0.1', 0)
  server.addr[1]
ensure
  server.close if server
end

def runner_url(server_port)
  "http://localhost:#{server_port}/__specs__/support/jasmine-1.3.1/spec-runner.html"
end

def start_server(server_port)
  Thread.abort_on_exception = true
  server_thread = Thread.new do
    Rack::Handler::Thin.run EnhancedWars::SpecsApp, :Port => server_port
  end

  uri = URI.parse(runner_url(server_port))
  attempts = 10
  begin
    sleep 1
    begin
      status = Net::HTTP.get_response(uri).code.to_i
    rescue Errno::ECONNREFUSED
    end
    attempts -= 1
  end while attempts > 0 && status != 200

  if attempts < 0
    raise "Could not connect to specs server after 10sec!"
  end
  server_thread
end

def report_spec(spec)
  return if spec['passed'] || spec['skipped']

  output = "- "
  output += spec['description']
  output += ": failed!"
  STDERR.puts output
end

def report_suite(suite)
  return if suite['passed']

  puts "#{suite['description']} (has failing specs):"
  suite['specs'].each do |spec|
    report_spec(spec)
  end
  puts ""
end

def report_results(result)
  result['suites'].each do |suite|
    report_suite(suite)
  end
end

RESULTS_SEPARATOR = '_______RESULTS_______'

namespace :specs do
  desc "Runs the JS specs"
  task :js do
    server_port = find_available_port
    server_thread = start_server(server_port)

    js_path = File.expand_path('../headless.js', __FILE__)
    cmd = "JASMINE_RUNNER_URL='#{runner_url(server_port)}' phantomjs --debug=yes #{js_path}"
    output = `#{cmd}`
    output.sub!(/^.*?#{RESULTS_SEPARATOR}\n/m, '')
    output.sub!(/#{RESULTS_SEPARATOR}.*$/m, '')
    raise "No JSON results found :/" if output.length < 1
    result = JSON.parse(output)
    report_results(result)

    server_thread.terminate

    if result['passed']
      puts "All specs passed."
    else
      STDERR.puts "JS specs failed!"
      exit false
    end
  end
end
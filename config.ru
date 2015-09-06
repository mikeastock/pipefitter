# Load path and gems/bundler
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "bundler"
Bundler.require

require "dotenv"
Dotenv.load

require "sidekiq"
Sidekiq.configure_client do |config|
  config.redis = { size: 1 }
end

require "sidekiq/web"
Sidekiq::Web.use(Rack::Session::Cookie, secret: ENV["RACK_SESSION_COOKIE"])

# Load app
require "pipefitter"

run Rack::URLMap.new("/" => Pipefitter::App, "/sidekiq" => Sidekiq::Web)

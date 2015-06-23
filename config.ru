require './myapp'
require 'sidekiq/web'
require 'sidekiq-status/web'

run Rack::URLMap.new('/' => Sinatra::Application, '/sidekiq' => Sidekiq::Web)

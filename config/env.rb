ENV["REDISTOGO_URL"] ||= ENV["BOXEN_REDIS_URL"] || 'redis://localhost:6379/'
ENV['SENDGRID_USERNAME'] ||= 'app38125127@heroku.com'
ENV['SENDGRID_PASSWORD'] ||= 'cxejg6af4869'

require 'active_support/all'
require 'json'
require 'redis'
require 'sidekiq'
require 'sidekiq-status'
require 'mail'

if development?
  require 'sinatra/reloader'
  require 'better_errors'
  require 'pry'
end

require './model/contact_finder'
require './model/contact_sender'
require './worker/contact_finder_worker'

Time.zone = "Brasilia"

redis_url = URI.parse(ENV["REDISTOGO_URL"])
$redis = Redis.new(host: redis_url.host, port: redis_url.port, password: redis_url.password)

Sidekiq.configure_client do |config|
  config.redis = { namespace: 'contact-finder', url: redis_url.to_s, size: 1 }
  config.client_middleware do |chain|
    chain.add(Sidekiq::Status::ClientMiddleware)
  end
end

Sidekiq.configure_server do |config|
  config.redis = { namespace: 'contact-finder', url: redis_url.to_s, size: 8 }
  config.server_middleware do |chain|
    chain.add(Sidekiq::Status::ServerMiddleware, expiration: 2.hours)
  end
end

Mail.defaults do
  delivery_method :smtp, {
    :address              => 'smtp.sendgrid.net',
    :port                 => '587',
    :domain               => 'heroku.com',
    :user_name            => ENV['SENDGRID_USERNAME'],
    :password             => ENV['SENDGRID_PASSWORD'],
    :authentication       => :plain,
    :enable_starttls_auto => true
  }
end

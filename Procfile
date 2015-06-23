web: bundle exec rackup -s thin -p ${PORT:-5000}
worker: bundle exec sidekiq -r ./myapp.rb -v

require 'rubygems'
require 'sinatra'

require './config/env.rb'

get '/' do
  send_file 'view/index.html'
end

get '/asd' do
  puts settings.public_folder
  send_file File.join(settings.public_folder, '11298.jpg')
end

get '/download/:file_name' do
  content_type 'application/csv'
  attachment params['file_name']
  send_file "/tmp/#{params['file_name']}.csv"
end

post '/search' do
  file_name = "#{params['query'].parameterize}_#{Time.now.strftime("%Y-%m-%d_%H-%M-%S")}"
  path = "/tmp/#{file_name}.csv"
  pid = ContactFinderWorker.perform_async(params['query'], path, params['limit'])
  content_type :json
  { pid: pid, file_name: file_name }.to_json
end

get '/status/:pid' do
  pid = params['pid']
  status = Sidekiq::Status::get_all(pid)
  puts status
  content_type :json
  progress = status['total'].to_i.zero? ? 0 : (status['at'].to_f / status['total'].to_f * 100).to_i
  { status: status['status'], progress: progress, message: "#{status['status']}: #{status['message']}" }.to_json
end

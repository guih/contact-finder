require 'rubygems'
require 'sinatra'

require './config/env.rb'

def file_path(file_name)
  File.join(".", "tmp", "#{file_name}.csv")
end

get '/' do
  send_file 'view/index.html'
end

get '/download/:file_name' do
  content_type 'application/csv'
  attachment params['file_name']
  send_file file_path(params['file_name'])
end

post '/search' do
  file_name = "#{params['query'].parameterize}_#{Time.now.strftime("%Y-%m-%d_%H-%M-%S")}"
  pid = ContactFinderWorker.perform_async(params['query'], file_path(file_name), params['limit'])
  content_type :json
  { pid: pid, file_name: file_name }.to_json
end

get '/status/:pid' do
  pid = params['pid']
  status = Sidekiq::Status::get_all(pid)
  puts status
  content_type :json
  progress = status['total'].to_i.zero? ? 0 : (status['at'].to_f / status['total'].to_f * 100).to_i
  { status: status['status'], progress: progress, message: [status['status'], status['message']].join(": ") }.to_json
end

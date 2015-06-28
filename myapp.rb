require 'rubygems'
require 'sinatra'

require './config/env.rb'

get '/' do
  send_file 'view/index.html'
end

post '/search' do
  pid = ContactFinderWorker.perform_async(params['query'], params['limit'])
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

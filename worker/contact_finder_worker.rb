class ContactFinderWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(term, path, limit = nil)
    ContactFinder.new.search(term, path, limit) do |progress, total, web|
      self.total total
      at progress, "[#{progress}/#{total}] #{web.title} (#{web.uri})"
    end
    at 100
  end

end

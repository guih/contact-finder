class ContactFinderWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(mail_to, term, limit = nil)
    file_path = ContactFinder.new.search(term, limit.try(:to_i)) do |progress, total, web|
      self.total total
      at progress, "[#{progress}/#{total}] #{web.title} (#{web.uri})"
    end
    total 100
    at 99, "Sending email with contacts file"
    ContactSender.send(file_path, mail_to, "Contacts for search '#{term}'")
    at 100, "Contacts email successfully sent!"
  end
end

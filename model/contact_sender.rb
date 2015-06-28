require 'zipruby'

class ContactSender
  def self.send(file_path, to, subject = nil)
    out = file_path.gsub(/\.csv$/, '.zip')
    Zip::Archive.open(out, Zip::CREATE) { |ar| ar.add_file(file_path) }

    Mail.deliver do
      to to
      from 'contactfinder@herokuapp.com'
      subject subject || 'your contacts is ready'
      body "Your contacts file '#{File.basename(out)}' is ready"
      add_file out
    end
  end
end

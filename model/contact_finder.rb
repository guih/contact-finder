require 'httparty'
require 'google-search'
require 'csv'
require 'active_support/all'

class ContactFinder

  def initialize(max_search_level = 1)
    @visited_uris = Set.new([])
    @max_search_level = max_search_level
  end

  def domain(uri)
    uri.scan(/:\/\/w{3}?\.?([^\/]+)/).flatten.first
  end

  def scan_phones(uri, page, data)
    page.scan(/(((\+\s?)?55\s)?(\(0?[1-9]{2}\)|0?[1-9]{2})\s9?\d{4}[-\s]?\d{4})\b/).each do |match|
      phone = match.first.downcase.strip
      data[:phone][phone] = uri unless data[:phone][phone]
    end
  end

  def scan_emails(uri, page, data)
    page.scan(/(([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?))/).each do |match|
      email = match.first.downcase.strip
      data[:email][email] = uri unless data[:email][email]
    end
    data
  end

  def search_info(uri, data = Hash.new {|h,k| h[k] = {}}, level = 0)
    return data if level > @max_search_level || @visited_uris.include?(uri)
    @visited_uris << uri

    page = HTTParty.get(uri).body
    scan_emails(uri, page, data)
    # scan_phones(uri, page, data)

    page.scan(/href="([^"]+)"/).flatten.each do |link|
      link = domain(uri) + link if link.start_with? "/"
      link.gsub!(/[?#].*/i, '')
      next unless domain(uri) == domain(link)
      search_info(link, data, level + 1)
    end
    data
  rescue
    data
  end

  def path_for(term)
    File.join(".", "tmp", "#{term.parameterize}_#{Time.now.strftime("%Y-%m-%d_%H-%M-%S")}.csv")
  end

  def search(term, quantity = nil, language = 'pt-BR')
    quantity ||= 64
    count = 0
    path = path_for(term)
    CSV.open(path, 'w', col_sep: ';') do |csv|
      csv << %w(title google_search_result_url local_url email)
      loop do
        result = Google::Search::Web.new(offset: count, query: term, language: language)
        result.each do |web|
          count += 1
          data = search_info(web.uri)
          data[:email].each do |email, uri|
            csv << [web.title, web.uri, uri, email]
          end
          break if count >= quantity
          yield(count, quantity, web) if block_given?
        end
        break if count >= quantity || result.count == 0
      end
    end
    path
  end

end

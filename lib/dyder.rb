require 'logger'
require 'net/http'
require 'set'
require 'uri'

class Dyder

  def self.run(keyword)
    Dyder.new(keyword).run
  end

  def initialize(keyword, be_polite=true, limit=50)
    @keyword = keyword
    @polite = be_polite
    @limit = limit
    @sites = Set.new
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
  end

  def run
    next_site = "http://en.wikipedia.org/wiki/#{@keyword}"
    while @sites.size < @limit
      @sites.merge crawl next_site
      next_site = @sites.to_a.sample
    end
    @logger.info "Found #{@sites.size} sites:\n\t#{@sites.to_a.sort.join("\n\t")}"
  end

  private
  def crawl(path)
    @logger.debug "Crawling '#{path}'"
    parse get path
  end

  def get(path)
    begin
      response = Net::HTTP.get_response URI.parse URI.encode path
    rescue Exception => e
      @logger.warn "Error retrieving '#{path}': #{e}"
      return ''
    end
    if response.code != '200'
      @logger.warn "Failed to retrieve '#{path}': received HTTP #{response.code}"
      return ''
    end
    response.body
  end

  def parse(response)
    response.scan(/href="(https?:\/\/[^"\/]+?\/)[^"]*"/).flatten
  end

end

Dyder.run('Drum_kit')
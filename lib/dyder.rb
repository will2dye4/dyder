require 'logger'
require 'net/http'
require 'set'
require 'uri'

class Dyder

  DEFAULT_LIMIT = 50
  ERROR_RESPONSE_CODE = '0'
  SUCCESS_RESPONSE_CODE = '200'

  def self.run(keyword)
    Dyder.new(keyword).run
  end

  def initialize(keyword, be_polite=true, limit=DEFAULT_LIMIT)
    @keyword = keyword
    @polite = be_polite
    @limit = limit
    @sites = {}
    @candidates = Set.new
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
  end

  def run
    next_site = "http://en.wikipedia.org/wiki/#{@keyword}"
    while @sites.size < @limit
      crawl next_site
      @candidates.delete next_site
      next_site = @candidates.to_a.sample
    end
    @logger.info "Found #{@sites.size} sites:"
    @sites.each_pair do |site, result|
      @logger.info "#{site}: #{result[:hits]} hit(s), #{result[:error].nil? ? 'status: ' + result[:code] : 'error: ' + result[:error]}"
    end
  end

  private
  def crawl(path)
    @logger.debug "Crawling '#{path}'"
    sites = parse get path
    sites.each do |site|
      if @sites.has_key? site
        @sites[site][:hits] = @sites[site][:hits] + 1
      else
        @sites[site] = {:hits => 1, :code => SUCCESS_RESPONSE_CODE, :error => nil}
      end
      @candidates.add site
    end
    sites
  end

  def get(path)
    begin
      uri = URI.parse URI.encode path
      response = Net::HTTP.get_response uri
    rescue Exception => e
      @logger.debug "Error retrieving '#{path}': #{e}"
      @sites[path] = {:hits => 1, :code => ERROR_RESPONSE_CODE, :error => e.to_s}
      return ''
    end
    if response.code != SUCCESS_RESPONSE_CODE
      @logger.debug "Failed to retrieve '#{path}': received HTTP #{response.code}"
      @sites[path] = {:hits => 1, :code => response.code, :error => nil}
      return ''
    end
    response.body
  end

  def parse(response)
    response.scan(/href="(https?:\/\/[^"\/]+?\/)[^"]*"/).flatten
  end

end

Dyder.run('Drum_kit')
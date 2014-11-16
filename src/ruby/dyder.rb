require 'net/http'
require 'set'
require 'uri'

class Dyder

  def initialize(keyword, be_polite)
    @keyword = keyword
    @polite = be_polite
    @sites = Set.new
    crawl
  end

  private

    def crawl
      next_site = "http://en.wikipedia.org/wiki/#{@keyword}"
      while @sites.size < 50
        puts "Crawling '#{next_site}'"
        @sites.merge do_crawl next_site
        next_site = @sites.to_a.sample
      end
      puts "Found #{@sites.size} sites:"
      @sites.each do |site|
        puts site
      end
    end

    def do_crawl(path)
      parse get(path)
    end

    def get(path)
      begin
        response = Net::HTTP.get_response(URI.parse(URI.encode(path)))
      rescue Exception => e
        puts "Error retrieving '#{path}': #{e}"
        return ''
      end
      if response.code != '200'
        puts "Failed to retrieve '#{path}': received HTTP #{response.code}"
        return ''
      end
      response.body
    end

    def parse(response)
      response.scan(/href="(https?:\/\/[^"\/]+?\/)[^"]*"/).flatten
    end

end

Dyder.new('Drum_kit', false)
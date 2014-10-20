# encoding: utf-8
require 'pismo/internal_attributes'
require 'pismo/external_attributes'

require 'net/http'

module Pismo

  # Pismo::Document represents a single HTML document within Pismo
  class Document

    attr_reader :doc, :url, :options

    ATTRIBUTE_METHODS = InternalAttributes.instance_methods + ExternalAttributes.instance_methods
    DEFAULT_OPTIONS = {
      :image_extractor => false,
      :min_image_width => 100,
      :min_image_height => 100
    }

    include Pismo::InternalAttributes
    include Pismo::ExternalAttributes

    def initialize(handle, options = {})
      @options = DEFAULT_OPTIONS.merge options
      url = @options.delete(:url)
      load(handle, url)
    end

    # An HTML representation of the document
    def html
      @doc.to_s
    end

    def load(handle, url = nil)
      @url = url if url
      @url = handle if handle =~ /\Ahttp/i

      @html = if handle =~ /\Ahttp/i
                fetch @url
              elsif handle.is_a?(StringIO) || handle.is_a?(IO) || handle.is_a?(Tempfile)
                handle.read
              else
                handle
              end

      @doc = Nokogiri::HTML(@html)
    end

    def match(args = [], all = false)

      @doc.match([*args], all)
    end

    def fetch(uri_str, limit = 20)
      
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0

      url = URI.parse(uri_str)
      @url = uri_str
      req = Net::HTTP::Get.new(url.path, { 'User-Agent' => ua })
      response = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
      case response
      when Net::HTTPSuccess     then response
      when Net::HTTPRedirection then fetch(response['location'], limit - 1)
      else
        response.error!
      end
    end
  
  end
end

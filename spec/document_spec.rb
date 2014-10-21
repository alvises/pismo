require 'spec_helper'

describe Pismo::Document do

	it "should redirects and get the content" do
		url = "http://blog.poeticoding.com"
    final_url = "http://www.poeticoding.com"

    doc = Pismo::Document.new url
    expect(doc.html_body).to_not be_nil
	end
	
	it "should redirects and get the content" do
		url = "http://t.co/FMAkySYwH9"
    final_url = "http://krugman.blogs.nytimes.com/2014/10/15/inequality-explained"
    url2 = "http://nyti.ms/11papuc"
    puts fetch(final_url).body
	end


    def fetch(uri_str, limit = 10)
      # You should choose a better exception.
      raise ArgumentError, 'too many HTTP redirects' if limit == 0

      response = Net::HTTP.get_response(URI(uri_str))

      case response
      when Net::HTTPSuccess then
        response
      when Net::HTTPRedirection then
        location = response['location']
        warn "redirected to #{location}"
        fetch(location, limit - 1)
      else
        response.value
      end
    end
  




end
require 'net/http'
require 'json'
module Ethereum
  class HttpClient < Client
    attr_accessor :host, :port, :uri, :ssl, :proxy

    def initialize(host, proxy = nil, log = false)
      super(log)
      uri = URI.parse(host)
      raise ArgumentError unless ['http', 'https'].include? uri.scheme
      @host = uri.host
      @port = uri.port
      @proxy = proxy

      @ssl = uri.scheme == 'https'
      @uri = URI("#{uri.scheme}://#{@host}:#{@port}#{uri.path}")
    end

    def send_single(payload)
      client = RestClient::Resource.new(uri.to_s)
      client.post(payload, accept: 'json', content_type: 'json' )
    end

    def send_batch(batch)
      result = send_single(batch.to_json)
      result = JSON.parse(result)
      result.sort_by! { |c| c['id'] }
    end
  end

end

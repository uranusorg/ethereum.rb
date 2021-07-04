require 'net/http'
require 'json'

module Ethereum
  class HttpClient < Client
    attr_accessor :host, :user, :pass, :port, :uri, :ssl, :proxy, :headers

    def initialize(host, proxy = nil, log = false, headers={})
      super(log)
      uri = URI.parse(host)
      raise ArgumentError unless ['http', 'https'].include? uri.scheme
      @host = uri.host
      @user = uri.user
      @pass = uri.password
      @port = uri.port
      @proxy = proxy
      @headers = headers

      @ssl = uri.scheme == 'https'
      @uri = URI("#{uri.scheme}://#{@user}:#{@pass}@#{@host}:#{@port}#{uri.path}")
    end

    def send_single(payload)
      client = RestClient::Resource.new(uri.to_s)
      @headers.merge!({ accept: 'json', content_type: 'json' })
      client.post(payload, @headers)
    end

    def send_batch(batch)
      result = send_single(batch.to_json)
      result = JSON.parse(result)
      result.sort_by! { |c| c['id'] }
    end
  end

end

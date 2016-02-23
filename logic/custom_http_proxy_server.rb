require 'webrick'
require 'webrick/httpproxy'

class CustomHTTPProxyServer < WEBrick::HTTPProxyServer
  @@cache = {}

  def service(req, res)
    if req.request_method == "GET" && @@cache.include?(req.request_line) && !ProxyHttpServer.blocked_hosts.any? { |host| req.request_line.include?(host) } && !req.request_line.include?("localhost")
      socket = Thread.current[:WEBrickSocket]
      @@cache[req.request_line].send_response socket

      message = {:command => 'new_traffic', :traffic_type => 'cached', :request => req.request_line}
      ProxyHttpServer.clients.each do |client|
        client.send message.to_json
      end
    elsif req.unparsed_uri =~ %r!^http://! ||req.unparsed_uri =~ %r!^https://!
      proxy_service(req, res)
    else
      super(req, res)
    end
  end

  def self.cache
    @@cache
  end
end
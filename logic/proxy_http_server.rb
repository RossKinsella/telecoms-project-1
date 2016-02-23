require_relative 'custom_http_proxy_server.rb'
require_relative 'management_console.rb'
require_relative 'cache.rb'
require_relative 'blocker.rb'
require 'webrick'
require 'webrick/httpproxy'

require 'em-websocket'
require 'json'

PROXY_PORT = 3020

class ProxyHttpServer
  attr_accessor :management_console


  def proxy_content_handler(req, res)
    if Blocker.is_blocked? req
      res.header['content-type'] = 'text/html'
      res.header.delete('content-encoding')
      res.body = "Access is denied."

      message = {:command => 'new_traffic', :traffic_type => 'blocked', :request => req.request_line}
      ManagementConsole.message_clients message

      socket = Thread.current[:WEBrickSocket]
      res.send_response socket
    else
      if(!Cache.contains?(req) && Cache.eligible_for_caching?(req, res))
        Cache.cache(req, res)
      else
        # Fetched directly
        message = {:command => 'new_traffic', :traffic_type => 'fetched_from_net', :request => req.request_line}
        ManagementConsole.message_clients message
      end
    end

  end

  def initialize
    root = File.expand_path "../"

    @server = CustomHTTPProxyServer.new(
        :Port => PROXY_PORT,
        :ProxyContentHandler => method(:proxy_content_handler),
        :DocumentRoot => root
    )

    @server.mount_proc '/management_console' do |req, res|
      res.body = ManagementConsole.render_console
    end
  end

  def start
    puts "Starting proxy"
    @server.start
  end

  server = ProxyHttpServer.new

  service = Thread.new do
    server.start
  end

  Thread.new do
    ManagementConsole.start
  end

  service.join

end



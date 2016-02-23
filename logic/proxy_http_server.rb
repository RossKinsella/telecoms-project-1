require_relative 'custom_http_proxy_server.rb'
require 'webrick'
require 'webrick/httpproxy'
require 'set'
require 'em-websocket'
require 'json'

PROXY_PORT = 3020
MANAGEMENT_CONSOLE_PORT = 4020

MIN_CACHE_RESPONSE_SIZE = 5000

class ProxyHttpServer
  @@blocked_hosts = Set.new ['youtube.com', 'www.facebook.com']

  def proxy_content_handler(req, res)
    if @@blocked_hosts.any? { |host| req.request_line.include?(host) }
      res.header['content-type'] = 'text/html'
      res.header.delete('content-encoding')
      res.body = "Access is denied."

      message = {:command => 'new_traffic', :traffic_type => 'blocked', :request => req.request_line}
      @@clients.each do |client|
        client.send message.to_json
      end

      socket = Thread.current[:WEBrickSocket]
      res.send_response socket
    else
      if(req.request_method == "GET" && !req.request_line.include?("localhost")) && res.body.size > MIN_CACHE_RESPONSE_SIZE
        # Added to cache
        CustomHTTPProxyServer.cache[req.request_line] = res
        message = {:command => 'new_traffic', :traffic_type => 'added_to_cache', :request => req.request_line}
        @@clients.each do |client|
          client.send message.to_json
        end
      else
        # Fetched directly
        message = {:command => 'new_traffic', :traffic_type => 'fetched_from_net', :request => req.request_line}
        ProxyHttpServer.clients.each do |client|
          client.send message.to_json
        end
      end
    end

  end

  def self.clients
    @@clients
  end

  def self.blocked_hosts
    @@blocked_hosts
  end

  def self.block_host host
    if !@@blocked_hosts.include? host
      @@blocked_hosts.add host
      message = {:command => 'new_block', :host => host}
      @@clients.each do |client|
        client.send message.to_json
      end
    end
  end

  def self.unblock_host host
    if @@blocked_hosts.include? host
      @@blocked_hosts.delete host
      message = {:command => 'removed_block', :host => host}
      @@clients.each do |client|
        client.send message.to_json
      end
    end
  end

  def self.management_console
    erb = ERB.new(File.open(File.expand_path("../../public/html/management_console.html.erb", __FILE__)).read)
    erb.result binding
  end

  def initialize_proxy
    puts 'Starting proxy'
    root = File.expand_path "../"

    server = CustomHTTPProxyServer.new(
        :Port => PROXY_PORT,
        :ProxyContentHandler => method(:proxy_content_handler),
        :DocumentRoot => root
    )

    server.mount_proc '/management_console' do |req, res|
      res.body = ProxyHttpServer.management_console
    end

    server.mount_proc '/block' do |req, res|
      res.body = ProxyHttpServer.block_host req.query['host']
    end

    server.mount_proc '/unblock' do |req, res|
      res.body = ProxyHttpServer.unblock_host req.query['host']
    end

    server.start
  end

  def initialize_management_console
    puts 'Starting management console'
    @@clients = []
    EventMachine::WebSocket.start(:host => "0.0.0.0", :port => MANAGEMENT_CONSOLE_PORT) do |ws|
      ws.onopen {
        puts "New client connected"
        @@clients << ws
      }
      ws.onmessage { |msg| 
        puts "Recieved #{msg}"
        msg = JSON.parse msg

        if msg["command"] == "block"
          host = msg["host"]
          ProxyHttpServer.block_host host

        elsif msg["command"] = "unblock"
          host = msg["host"]
          ProxyHttpServer.unblock_host host

        end
      }
      ws.onclose   {
        puts "WebSocket closed"
        @@clients.delete ws
      }
    end
  end

  def initialize
    proxy = Thread.new do
      begin
        initialize_proxy()
      rescue => e
        puts e
        puts e.backtrace
      end
    end

    management_console = Thread.new do
      begin
        initialize_management_console()
      rescue => e
        puts e
        puts e.backtrace
      end
    end

    proxy.join
    management_console.join
  end

  server = Thread.new do
    ProxyHttpServer.new
  end
  server.join
end



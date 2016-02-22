require 'webrick'
require 'webrick/httpproxy'
require 'set'

class ProxyHttpServer
  @@blocked_hosts = Set.new ['ign.com']

  def self.proxy_content_handler(req, res)
    # req.query['lala']
    # puts "//////////////////\n[REQUEST] " + req.request_line
    if @@blocked_hosts.include? req.host
      res.header['content-type'] = 'text/html'
      res.header.delete('content-encoding')
      res.body = "Access is denied."
    end
  end

  def self.block_host host
    @@blocked_hosts.add host
  end

  def self.unblock_host host
    @@blocked_hosts.delete host
  end

  def self.management_console
    erb = ERB.new(File.open(File.expand_path("../../public/html/blocked.html.erb", __FILE__)).read)
    erb.result binding
  end

  server = WEBrick::HTTPProxyServer.new(
    :Port => 8989,
    :ProxyContentHandler => method(:proxy_content_handler)
  )

  server.mount_proc '/' do |req, res|
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

server = Thread.new do
  begin
    ProxyHttpServer.new
  rescue => e
    puts e
    puts e.backtrace
  end
end

server.join

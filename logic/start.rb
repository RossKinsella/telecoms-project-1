require_relative 'proxy_service.rb'

server = ProxyService.new

service = Thread.new do
  server.start
end

Thread.new do
  ManagementConsole.start
end

service.join

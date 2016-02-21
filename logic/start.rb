require 'openssl'
require 'socket'
require_relative 'self_signed_certificate.rb'
require_relative 'logger.rb'
require_relative 'request_handler.rb'
require_relative 'https_server.rb'
require_relative 'http_server.rb'

https = Thread.new do
  begin
    HttpsServer.new
  end
end

http = Thread.new do
  begin
    HttpServer.new
  end
end

https.join
http.join
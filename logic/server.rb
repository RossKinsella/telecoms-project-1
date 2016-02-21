require 'openssl'
require 'socket'
require_relative 'self_signed_certificate.rb'
require_relative 'logger.rb'

IP = '127.0.0.1'
PORT = 8000

class Server
  # Setup
  self_signed_certificate = SelfSignedCertificate.new
  cert = self_signed_certificate.cert
  pkey = self_signed_certificate.private_key

  server = TCPServer.new IP, PORT
  Logger.log "Server started at #{IP}:#{PORT}"

  loop do
    Thread.start(server.accept) do |socket|
      Logger.log 'New connection accepted'
      begin
        request = socket.gets
        Logger.log "Request: #{request}"

        response = File.open("#{Dir.pwd}/public/html/proxy_start.html").read

        socket.print "HTTP/1.1 200 OK\r\n" +
                     "Content-Type: text/html\r\n" +
                     "Content-Length: #{response.bytesize}\r\n" +
                     "Connection: close\r\n\r\n"

        # Print the actual response body, which is just "Hello World!\n"
        socket.print response

        # Close the socket, terminating the connection
        socket.close
      rescue => e
        Logger.log e
        # Close the socket, terminating the connection
        socket.close
      end
    end

  end
end

server = Server.new
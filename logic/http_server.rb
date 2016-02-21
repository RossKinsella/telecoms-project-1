require 'socket'
require_relative 'logger.rb'

class HttpServer
  @@ip = '127.0.0.1'
  @@port = 8001

  def initialize
    server = TCPServer.new @@ip, @@port
    Logger.log "HTTP Server started at #{@@ip}:#{@@port}"

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

end

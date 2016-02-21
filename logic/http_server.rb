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
          RequestHandler.handle_request request, socket
        rescue => e
          Logger.log e
          # Close the socket, terminating the connection
          socket.close
        end
      end

    end
  end

end

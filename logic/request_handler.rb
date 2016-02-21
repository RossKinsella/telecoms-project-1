class RequestHandler

  def self.handle_request request, socket
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
  end

end
class RequestHandler

  def self.handle_request request, socket
    Logger.log "Request: #{request}"

    if request.split('?')[1]
      paramstring = request.split('?')[1]     # chop off the verb
      paramstring = paramstring.split(' ')[0] # chop off the HTTP version
      params = CGI::parse paramstring    # only handles two parameters
    else
      params = {}
    end

    if params["url"]
      response = File.open("#{Dir.pwd}/public/html/blocked.html").read
    else
      response = File.open("#{Dir.pwd}/public/html/proxy_start.html").read
    end

    socket.print "HTTP/1.1 200 OK\r\n" +
                 "Content-Type: text/html\r\n" +
                 "Content-Length: #{response.bytesize}\r\n" +
                 "Connection: close\r\n\r\n"

    socket.print response

    socket.close
  end

end
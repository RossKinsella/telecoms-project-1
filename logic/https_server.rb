require 'openssl'
require 'socket'
require_relative 'self_signed_certificate.rb'
require_relative 'logger.rb'

class HttpsServer

  @@ip = '127.0.0.1'
  @@port = 8000

  def initialize
    self_signed_certificate = SelfSignedCertificate.new
    cert = self_signed_certificate.cert
    pkey = self_signed_certificate.private_key

    sslContext = OpenSSL::SSL::SSLContext.new
    sslContext.cert = cert
    sslContext.key = pkey
    sslContext.ssl_version = :SSLv23

    server = TCPServer.new @@ip, @@port
    sslServer = OpenSSL::SSL::SSLServer.new( server, sslContext );
    sslServer.start_immediately = true;
    Logger.log "HTTPS Server started at #{@@ip}:#{@@port}"

    loop do
      begin
        Thread.start(sslServer.accept) do |socket|
          Logger.log 'New connection accepted'
          

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
        end
      rescue => e
        Logger.log e
        # Close the socket, terminating the connection
      end
    end
  end

end
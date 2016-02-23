require 'webrick'
require 'webrick/httpproxy'

class CustomHTTPProxyServer < WEBrick::HTTPProxyServer

  def service(req, res)
    if Cache.contains? req
      socket = Thread.current[:WEBrickSocket]
      res = Cache.retrieve req
      res.send_response socket
    elsif req.unparsed_uri =~ %r!^http://! ||req.unparsed_uri =~ %r!^https://!
      proxy_service(req, res)
    else
      super(req, res)
    end
  end

end
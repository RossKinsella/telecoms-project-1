require 'webrick'
require 'webrick/httpproxy'

class CustomHTTPProxyServer < WEBrick::HTTPProxyServer
  def service(req, res)
    if req.unparsed_uri =~ %r!^http://! ||req.unparsed_uri =~ %r!^https://!
      proxy_service(req, res)
    else
      super(req, res)
    end
  end
end
require 'webrick'
require 'webrick/httpproxy'

# Extension of a proxy server offered in the ruby std library.
# The base proxy server does not allow for intercepting https traffic and has no Caching/Blocking functionality.
class CustomHTTPProxyServer < WEBrick::HTTPProxyServer

  # Called on every request
  def service(req, res)
    # Attempt to resolve at block
    if Blocker.is_blocked? req
      res.header['content-type'] = 'text/html'
      res.header.delete('content-encoding')
      res.body = "Access is denied."

      message = {:command => 'log_traffic',
                 :traffic_type => 'blocked',
                 :request => req.request_line}
      ManagementConsole.message_clients message

      socket = Thread.current[:WEBrickSocket]
      res.send_response socket

    # Attempt to resolve at cache
    elsif Cache.contains? req
      socket = Thread.current[:WEBrickSocket]
      res = Cache.retrieve req
      res.send_response socket

    # Resolve over network
    elsif req.unparsed_uri =~ %r!^http://! ||req.unparsed_uri =~ %r!^https://!
      proxy_service(req, res)

    # Ignore anything that is not http/https
    else
      super(req, res)

    end

  end

end

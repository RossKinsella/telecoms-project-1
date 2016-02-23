require_relative 'custom_http_proxy_server.rb'
require_relative 'management_console.rb'
require_relative 'cache.rb'
require_relative 'blocker.rb'

PROXY_PORT = 3020

class ProxyService

  # Callback for any messages we satisfied at the network level.
  # IE those which could not be resolved by the cache or ended at the blocking phase.
  def proxy_content_handler(req, res)
    if(!Cache.contains?(req) && Cache.eligible_for_caching?(req, res))
      Cache.cache(req, res)
    else
      message = {:command => 'log_traffic',
                 :traffic_type => 'satisfied_over_network_and_not_cached',
                 :request => req.request_line}
      ManagementConsole.message_clients message
    end
  end

  def initialize
    root = File.expand_path '../'
    @server = CustomHTTPProxyServer.new(
        :Port => PROXY_PORT,
        :ProxyContentHandler => method(:proxy_content_handler),
        :DocumentRoot => root
    )

    # Declare management console resource
    @server.mount_proc '/management_console' do |req, res|
      res.body = ManagementConsole.render_console
    end
  end

  def start
    puts 'Starting proxy'
    @server.start
  end

end



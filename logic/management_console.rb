require 'em-websocket'
require 'json'

class ManagementConsole
  MANAGEMENT_CONSOLE_PORT = 4020

  @@clients = [] # The currently connected WebSockets to the Management Console

  def self.start
    puts 'Starting management console'
    EventMachine::WebSocket.start(:host => '0.0.0.0', :port => MANAGEMENT_CONSOLE_PORT) do |ws|
      ws.onopen {
        puts 'New client connected'
        @@clients << ws
      }
      ws.onmessage { |msg|
        puts "Recieved #{msg}"
        msg = JSON.parse msg

        if msg['command'] == 'block'
          host = msg['host']
          Blocker.block_host host

        elsif msg['command'] = 'unblock'
          host = msg['host']
          Blocker.unblock_host host

        end
      }
      ws.onclose   {
        puts 'WebSocket closed'
        @@clients.delete ws
      }
    end
  end

  # Message all connected WebSockets with the contents of a Hash
  def self.message_clients message
    @@clients.each do |client|
      client.send message.to_json
    end
  end

  # Returns a html document for the management console
  def self.render_console
    blocked_hosts = Blocker.blocked_hosts # Set context for ERB template engine.
    erb = ERB.new(File.open(File.expand_path('../../public/html/management_console.html.erb', __FILE__)).read)
    erb.result binding
  end

end
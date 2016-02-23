require 'set'

class Blocker
  @@blocked_hosts = Set.new ['youtube.com', 'www.facebook.com']

  def self.blocked_hosts
    @@blocked_hosts
  end

  def self.block_host host
    if !@@blocked_hosts.include? host
      @@blocked_hosts.add host
      message = {:command => 'new_block', :host => host}
      ManagementConsole.message_clients message
    end
  end

  def self.unblock_host host
    if @@blocked_hosts.include? host
      @@blocked_hosts.delete host
      message = {:command => 'removed_block', :host => host}
      ManagementConsole.message_clients message
    end
  end

  def self.is_blocked? request
    @@blocked_hosts.any? { |host| request.request_line.include?(host) }
  end

end


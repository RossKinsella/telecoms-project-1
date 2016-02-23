MIN_CACHED_RESPONSE_SIZE = 5000

class Cache
  @@entries = {}

  def self.contains? (request)
    @@entries.include? request.request_line
  end

  def self.retrieve (request)
    message = {:command => 'new_traffic', :traffic_type => 'cached', :request => request.request_line}
    ManagementConsole.message_clients message
    @@entries[request.request_line]
  end

  def self.cache (request, response)
    @@entries[request.request_line] = response
    message = {:command => 'new_traffic', :traffic_type => 'added_to_cache', :request => request.request_line}
    ManagementConsole.message_clients message
  end

  def self.eligible_for_caching? (request, response)
    request.request_method == "GET" &&
      response.body &&
      response.body.size > MIN_CACHED_RESPONSE_SIZE &&
      !request.request_line.include?('localhost') &&
      !Blocker.is_blocked?(request)
  end

end
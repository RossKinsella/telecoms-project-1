class Logger  
  @@enabled = true
  @@count_threads = false
  @@thread_ids = {}
  @@iterator = 0
  
  def self.log message
    if @@enabled
      if @@thread_ids.include? Thread.current.object_id
        current = @@thread_ids[Thread.current.object_id]
      else
        current = @@iterator
        @@thread_ids[Thread.current.object_id] = current
        @@iterator = @@iterator.next
      end
      if @@count_threads
        puts "Thread ##{current} :: #{message}\n"
      else
        puts "#{message}\n"
      end
    end
  end

end

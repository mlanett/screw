require "thread"

class Thread

  alias default_join join
  def join
    begin
      default_join
    rescue Exception => x
      STDERR.puts "Could not join thread due to #{x.inspect}; thread=#{inspect} current=#{Thread.current.inspect}" + " backtrace=" + x.backtrace.join("&")
      raise
    end
    self
  end

  alias default_inspect inspect
  def inspect
    return default_inspect unless key?(:name)
    name   = self[:name]
    status = alive? ? (stop? ? "sleep" : "run") : "dead"
    "<Thread:#{name} #{status}>"
  end

end

require "thread"

module Screw
  # Semaphore implements a resource counting control.
  # Call #wait! to acquire a resource.
  # Call #signal! to release one.
  # Originally based on https://gist.github.com/pettyjamesm/3746457, but rewritten and fixed.
  class Semaphore

    def initialize(max = nil, count = 0)
      max     = max.to_i unless max.nil?
      count   = count.to_i
      raise NonPositiveMax, max.to_s if max and max <= 0
      raise CountOverflow, count.to_s if max and max < count
      @max    = max
      @count  = count
      @mon    = Mutex.new
      @nempty = ConditionVariable.new
      @nfull  = ConditionVariable.new
    end
  
    def count
      @mon.synchronize { @count }
    end
  
    # e.g. release (back into pool)
    def signal!
      @mon.synchronize do
        @nfull.wait(@mon) while @max and @count == @max
        @count += 1
        @nempty.signal
      end
    end
  
    # e.g. acquire (from pool)
    def wait!
      @mon.synchronize do
        @nempty.wait(@mon) while @count == 0
        @count -= 1
        @nfull.signal
      end
    end

    class NonPositiveMax < ArgumentError
    end

    class CountOverflow < ArgumentError
    end

  end # Semaphore
end # Screw

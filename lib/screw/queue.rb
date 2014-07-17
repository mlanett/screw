require "thread"

module Screw
  class Queue

    Unlimited = 0
    Forever   = (2 ** (0.size * 8 - 2) - 1) # Ruby uses an extra bit as a Fixnum flag.
    NoWait    = 0

    class Timeout < ::Exception
    end

    # @param max is the maximum size of the queue. Optional, defaults to 0 (Unlimited).
    def initialize(max = Unlimited)
      raise max.inspect unless (Fixnum === max && max >= 0)
      @max    = max
      @queue  = []
      @mutex  = Mutex.new
      @nempty = ConditionVariable.new
      @nfull  = ConditionVariable.new
    end

    def push(it)
      @mutex.synchronize do
        while @max > 0 && @queue.size >= @max do
          @nfull.wait(@mutex)
        end

        # Push. But also if anyone else is waiting to pop, they can do it now.
        @queue << it
        @nempty.signal
        self
      end
    end

    # @param wait is timeout in seconds; Optional, defaults to Forever.
    # @raises Timeout in the event of a timeout
    def pop(wait = Forever)
      raise wait.inspect unless (Fixnum === wait && wait >= 0)

      @mutex.synchronize do
        while @queue.size == 0

          # Have we run out of time?
          raise Timeout if wait <= 0

          # Wait. Subtract wait time from timeout.
          now = Time.now.to_i
          @nempty.wait(@mutex, wait)
          wait -= (Time.now.to_i - now)
        end

        # Pop
        it = @queue.shift
        @nfull.signal
        it
      end # synchronize
    end # pop

    def inspect
      "#<#{self.class.name} [#{@queue.join(',')}]>"
    end

  end # Queue
end

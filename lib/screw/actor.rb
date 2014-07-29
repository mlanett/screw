require "thread"

module Screw
  # The Actor pattern is generally based on asynchronous method dispatch.
  # There is no return value (until/unless Future is implemented).
  #
  # To perform an actor dispatch, use the async helper, e.g.
  # => myactor.async.do_something(an_arg)
  #
  # Limitations:
  #
  # Because blocks execute in the Actor's thread but have access to the caller's state,
  # they are problematic and not supported.
  #
  # This Actor implementation does not support pipeline optimization.
  module Actor

    class Unsupported < ::Exception
    end

    class Stopped < ::Exception
    end

    def initialize
      @listening  = true
      @messages   = Queue.new
      @mutex      = Mutex.new
      @processing = true
      @thread     = Thread.new { run! }
    end

    def run!
      begin
        loop do
          #
          begin
            message = @messages.pop
          rescue Queue::Timeout
            nil # just go around again
          end
          #
          case message
          when nil # nop
            Thread.pass
            next
          when :stop
            @processing = false
            break
          when Call
            method, arguments, block = [message.method, message.arguments, message.block]
          else
            raise ArgumentError, "Unknown message #{message.inspect}"
          end
          #
          raise Unsupported, "block" if block
          raise Stopped if ! @processing
          result = self.send(method, *arguments)
          # Screw.logger.debug "Actor said #{method}; actor=#{self.inspect}"
          # TODO return result via a Future
        end # loop
      rescue => x
        Screw.logger.error "Actor messed up lines due to #{x.inspect}; actor=#{self.inspect}"
        raise
      ensure
        Screw.logger.info "Actor has left the stage; actor=#{self.inspect}"
      end
    end

    def async
      @async ||= Proxy.new(self) do |method, *arguments, &block|
        raise Unsupported, "block" if block
        @mutex.synchronize do
          raise Stopped if ! @listening
          @messages.push(Call.new method, arguments, nil)
        end
        nil # TODO return a Future
      end
    end

    def stop!
      # Screw.logger.debug "Stopping actor=#{self.inspect}"
      @mutex.synchronize do
        @messages.push(:stop) unless ! @listening
        @listening = false
      end
      self
    end

    def join!
      @thread.join
      self
    end

    class Call < Struct.new :method, :arguments, :block
      def to_s
        self.method.to_s
      end
    end

  end # Actor
end # Screw

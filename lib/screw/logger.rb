require "logger"
require "thread"

module Screw
  module Logger

    class SafeLogger

      def initialize(theLogger)
        @logger = theLogger
        @mutex  = Mutex.new
      end

      ::Logger::Severity.constants.each do |sym|
        level = ::Logger::Severity.const_get(sym)
        name  = sym.to_s.downcase.to_sym
        pred  = "#{name}?".to_sym
        define_method(name) do |message, progname = nil, &block|
          @mutex.synchronize do
            @logger.add(level, message, progname, &block)
          end
        end
        define_method(pred) do
          level >= @logger.level
        end
      end

      def close
        @mutex.synchronize do
          @logger.close
        end
      end

    end

    # SerializedLogger addresses the problem of writing to a logger from multiple threads.
    # This wraps a non-thread safe logger with a queue.
    # Thus it does not slow down the callers.
    # This logger does not support block parameters because we can't evaluate them safely AND lazily.
    # It also does not support the severity predicates: debug? etc.
    class SerializedLogger

      def initialize(theLogger)
        @logger = theLogger
        @lines  = Screw::Queue.new
        @actor  = Thread.new do
          loop do
            line = @lines.pop
            break if line == CLOSE
            level, message = *line
            @logger.add(level, message)
          end
        end
      end

      ::Logger::Severity.constants.each do |sym|
        level = ::Logger::Severity.const_get(sym)
        name = sym.to_s.downcase.to_sym
        define_method(name) do |message,&block|
          raise "blocks are unsupported" if block
          add(level, message)
        end
      end

      def close
        @lines.push CLOSE
      end

      private

      def add(level, message)
        @lines.push [ level, message ]
      end

      CLOSE = Object.new

    end # SerializedLogger

    def logger=(aLogger)
      Thread.exclusive do
        @@logger = aLogger
      end
    end

    def logger
      @@logger ||= begin
        Thread.exclusive do
          @@logger ||= SafeLogger.new(::Logger.new(STDERR))
        end
      end
    end

  end # Logger
end # Screw


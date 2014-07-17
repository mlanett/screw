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
        define_method(name) do |message = nil, progname = nil, &block|
          # Executing blocks in this mutex is not be a good idea. Resolve them first.
          if block && (level >= @logger.level)
            message = block.call.to_s
          end
          @mutex.synchronize do
            @logger.add(level, message, progname)
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

    # This logger will be shared by every class which includes the module. It's global.
    def logger=(aLogger)
      Thread.exclusive do
        @@logger = aLogger
      end
    end

    def logger
      # I'm assuming that reads are atomic.
      @@logger ||= begin
        Thread.exclusive do
          @@logger ||= SafeLogger.new(::Logger.new(STDERR))
        end
      end
    end

  end # Logger
end # Screw

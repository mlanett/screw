require "logger"
require "thread"

module Screw
  class Logger

    def initialize(theLogger)
      @logger = theLogger
      @mutex  = Mutex.new
    end

    ::Logger::Severity.constants.each do |sym|
      level = ::Logger::Severity.const_get(sym)
      name  = sym.to_s.downcase
      pred  = name + "?"
      define_method(name) do |message = nil, progname = nil, &block|
        if level >= @logger.level # Unprotect access to #level is probably Ok.
          # Executing blocks in this mutex is not be a good idea. Resolve them first.
          message = block.call.to_s if block
          @mutex.synchronize do
            @logger.add(level, message, progname)
          end
        end
      end
      define_method(pred) do
        level >= @logger.level # Unprotect access to #level is probably Ok.
      end
    end

    def close
      @mutex.synchronize do
        @logger.close
      end
    end

  end # Logger
end # Screw

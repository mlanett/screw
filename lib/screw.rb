require "screw/version"
require "logger"

module Screw
  autoload :Logger,     "screw/logger"
  autoload :Proxy,      "screw/proxy"
  autoload :Queue,      "screw/queue"
  autoload :Semaphore,  "screw/semaphore"

  class << self
    @@logger = begin
      base = ::Logger.new(STDERR)
      base.formatter = ->(severity, datetime, program, message) do
        "%s pid=%i %s: %s\n" % [datetime.utc.strftime("%Y-%m-%dT%H:%M:%S"), Process.pid, severity.to_s[0], message]
      end
      Logger.new(base)
    end

    def logger=(aLogger)
      @@logger = aLogger
    end

    def logger
      @@logger
    end
  end # self
end

require "screw/version"

module Screw
  autoload :Logger, "screw/logger"
  autoload :Proxy,  "screw/proxy"
  autoload :Queue,  "screw/queue"

  extend Logger
end

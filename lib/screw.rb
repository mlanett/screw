require "screw/version"

module Screw
  autoload :Logger, "screw/logger"
  autoload :Queue,  "screw/queue"

  extend Logger
end

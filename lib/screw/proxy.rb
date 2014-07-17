module Screw
  # Proxy allows you to intercept calls to one object and divert them to a handler.
  # Each method call is memoized using method_missing/define_method.
  class Proxy

    def initialize(target, &block)
      @target = target
      @block  = block
    end

    def method_missing(method, *arguments, &block)
      raise ::NoMethodError, method.to_s if ! @target.respond_to?(method)
      self.singleton_class.send(:define_method, method) do |*arguments,&block|
        @block.call(method, *arguments, &block)
      end
      send(method, *arguments, &block)
    end

  end # Proxy
end # Screw

module Screw
  class Worker
    include Actor

    def initialize(listener)
      super()
      self.listener = listener
    end

    def perform job
      with_job(job) do
        listener.working(self)
        sleep rand
        listener.ready(self)
      end
    end

    def with_job job # yield
      self.job = job
      # Screw.logger.debug "#{self} performing #{job}"
      yield
    ensure
      self.job = nil
      Screw.logger.info "#{self} performed #{job}"
    end

    def to_s
      if job
        "%s#%x(%s)" % [ self.class.name, self.object_id, job.to_s ]
      else
        "%s#%x" % [ self.class.name, self.object_id ]
      end
    end

    protected
    attr_accessor :job
    attr_accessor :listener
  end # Worker
end # Screw

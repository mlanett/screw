module Screw
  class Worker
    include Actor

    def initialize(listener)
      super()
      self.listener = listener
    end

    def perform job
      with_job(job) do
        listening do
          sleep rand
        end
      end
    end

    def with_job job # block
      self.job = job
      yield
    ensure
      self.job = nil
      Screw.logger.info "#{self} performed #{job}"
    end

    def listening # block
      listener.working(self)
      yield
    ensure
      listener.ready(self)
    end

    def to_s
      if job
        "<%s#%x %s>" % [ self.class.name, self.object_id, job.to_s ]
      else
        "<%s#%x>" % [ self.class.name, self.object_id ]
      end
    end

    protected
    attr_accessor :job
    attr_accessor :listener
  end # Worker
end # Screw

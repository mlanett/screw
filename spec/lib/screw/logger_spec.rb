require "spec_helper"
require "logger"
require "stringio"

describe Screw::Logger::SafeLogger do

  let(:buffer) { StringIO.new("") }
  let(:base)   { ::Logger.new(buffer).tap { |it| it.formatter = ->(severity, datetime, program, message) { "#{message}\n" } } }
  subject      { Screw::Logger::SafeLogger.new(base) }

  it "logs" do
    subject.info "Hello, world"
    expect(buffer.string).to eq "Hello, world\n"
  end

  it "resolves blocks" do
    subject.info { "Hello, world" }
    expect(buffer.string).to eq "Hello, world\n"
  end

  it "does not log to quiet loggers" do
    base.level = 1
    subject.debug "This is a test."
    expect(buffer.string.size).to eq 0
    subject.debug { "This is also a test." }
    expect(buffer.string.size).to eq 0
  end

  it "does not interleave output", stress: true do
    subject # force
    ((1..100).map { Thread.new { subject.info "Hello, world" } }).shuffle.map(&:join)
    expect(buffer.string).to eq "Hello, world\n" * 100
  end

end

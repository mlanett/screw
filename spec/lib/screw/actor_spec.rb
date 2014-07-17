require "spec_helper"

class ActorTest
  include Screw::Actor
  def initialize
    super()
    @n = 0.0
    @t = 0.0
  end
  def add it
    @n += 1
    @t += it
    self
  end
  def n() @n end
  def t() @t end
  def avg() @t / @n end
  def to_s
    "Actor##{hash}"
  end
end

describe Screw::Actor do

  subject     { ActorTest.new }
  before      { (subject) } # force evaluation before threads run
  after       { subject.stop!.join! }

  it "processes methods" do
    subject.async.add(1)
    expect(subject.stop!.join!.n).to eq 1
  end

  it "does not process methods after stop" do
    subject.async.add(1)
    subject.stop!
    expect { subject.async.add(1) }.to raise_exception
  end

  it "processes methods from multiple threads" do
    (1..100).map { |i| Thread.new { subject.async.add(i%2 * 2 - 1) } }.map(&:join)
    subject.stop!.join!
    expect(subject.n).to eq 100
    expect(subject.avg).to eq 0
  end

end

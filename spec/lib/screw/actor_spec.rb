require "spec_helper"

class TestActor
  include Screw::Actor

  def initialize
    super()
    @a = 0
    @b = 1
  end

  def tick
    @a,@b = @b,(@a+@b)
  end

  def tock
    @a
  end

  def to_s
    "Actor##{hash}"
  end
end

describe Screw::Actor do

  subject     { TestActor.new }
  before      { (subject) } # force evaluation before threads run
  after       { subject.stop!.join! }

  it "processes methods" do
    subject.async.tick
    expect(subject.stop!.join!.tock).to eq 1
  end

  it "does not process methods after stop" do
    subject.async.tick
    subject.stop!
    expect { subject.async.tick }.to raise_exception
  end

  it "processes methods from multiple threads" do
    (1..100).map { |i| Thread.new { subject.async.tick } }.map(&:join)
    subject.stop!.join!
    expect(subject.tock).to eq 354224848179261915075
  end

  it "idles if it has nothing else to do" do
    subject.idle! :tick
    Thread.pass until subject.tock > 0 # not entirely thread-safe but I haven't worked out a good way to extract results from Actors yet.
  end

end

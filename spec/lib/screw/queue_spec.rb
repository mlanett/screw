require "spec_helper"

describe Screw::Queue do

  subject { Screw::Queue.new }

  it "can push and pop ordered in same thread" do
    subject.push :a
    subject.push :b
    expect(subject.pop).to eq :a
    expect(subject.pop).to eq :b
  end

  it "can push and pop in different threads" do
    Thread.new do
      subject.push :a
      subject.push :b
    end
    expect(subject.pop).to eq :a
    expect(subject.pop).to eq :b
  end

end

require "spec_helper"

describe Screw::Semaphore do

  let(:num) { 25 }
  let(:max) { 5 }
  subject   { Screw::Semaphore.new(nil, max) }
  before    { expect(subject.count).to eq max }
  after     { expect(subject.count).to eq max }

  it "does not deadlock", stress: true do
    t = (1..num).map do
      Thread.new do
        subject.wait!
        sleep rand
        subject.signal!
      end
    end
    t.map(&:join)
  end

end

require "spec_helper"

class ProxyTest
  attr_accessor :a, :b
  def one(a)
    self.a = a
    self
  end
  def two(a,b)
    self.a = a
    self.b = b
    self
  end
  def pass(&block)
    block.call
  end
end

describe Screw::Proxy do

  let(:base)     { ProxyTest.new }
  subject        { Screw::Proxy.new(base,&handler) }
  let(:subject2) { Screw::Proxy.new(base,&handler) }

  describe "for one argument" do
    let(:handler) { ->(method, arg1, &block) { base.one(arg1) } }

    it "memoizes methods" do
      expect(subject).to_not respond_to(:one)

      expect(subject.one(0)).to eq base
      expect(subject).to respond_to(:one)

      expect(subject2).to_not respond_to(:one)
    end

    it "passes one argument and returns the source" do
      expect(subject.one(1)).to eq base
      expect(base.a).to eq 1
    end
  end

  describe "for two arguments" do
    let(:handler) { ->(method, arg1, arg2, &block) { base.two(arg1,arg2) } }
    it "passes one argument and returns the source" do
      subject.two(2,3)
      expect(base.a).to eq 2
      expect(base.b).to eq 3
    end
  end

  describe "for various arguments" do
    let(:handler) { ->(method, *arguments, &block) { base.send(method,*arguments) } }
    it "passes one argument and returns the source" do
      subject.one(4)
      expect(base.a).to eq 4
      subject.two(5,6)
      expect(base.a).to eq 5
      expect(base.b).to eq 6
    end
  end

  describe "with blocks" do
    let(:handler) { ->(method, *arguments, &block) { base.send(method,*arguments,&block) } }
    it "evaluates blocks" do
      expect(subject.pass { 3 }).to eq 3
    end
  end

end

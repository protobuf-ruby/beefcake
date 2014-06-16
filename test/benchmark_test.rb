require 'minitest/autorun'
require 'minitest/benchmark'
require 'beefcake'

class Inner
  include Beefcake::Message

  required :content, :string, 1
end

class Outer
  include Beefcake::Message

  repeated :inner, Inner, 1
end

class BenchmarkTest < Minitest::Benchmark
  def setup
    @buf = Beefcake::Buffer.new
  end

  def bench_read_string
    assert_performance_linear 0.75 do |n|
      candidate = 'x' * (n * 1_000)
      @buf.append_string candidate
      assert_equal candidate, @buf.read_string
    end
  end

  def bench_decode
    assert_performance_linear 0.75 do |n|
      inners = n.times.map{ Inner.new :content => 'x' * 100 }
      outer = Outer.new :inner => inners

      encoded = outer.encode.to_s

      decoded = Outer.decode encoded

      assert_equal n, decoded.inner.length
    end
  end
end

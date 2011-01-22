$:.unshift File.expand_path('../../lib', __FILE__)
require 'beefcake'

class MyMessage
  include Beefcake::Message
  required :number, :int32,  1
  required :chars,  :string, 2
  required :raw,    :bytes,  3
  required :bool,   :bool,   4
  required :float,  :float,  5
end

if ARGV[0] == 'pprof'
  # profile message creation/encoding/decoding w/ perftools.rb
  # works on 1.8 and 1.9
  #   ruby bench/simple.rb pprof
  #   open bench/beefcake.prof.gif

  ENV['CPUPROFILE_FREQUENCY'] = '4000'
  require 'rubygems'
  require 'perftools'
  PerfTools::CpuProfiler.start(File.expand_path("../beefcake.prof", __FILE__)) do
    100_000.times do
      str = MyMessage.new(
        :number => 12345,
        :chars  => 'hello',
        :raw    => 'world',
        :bool   => true,
        :float  => 1.2345
      ).encode
      MyMessage.decode(str)
    end
  end
  Dir.chdir(File.dirname(__FILE__)) do
    `pprof.rb beefcake.prof --gif > beefcake.prof.gif`
  end

else
  # benchmark message creation/encoding/decoding
  #   rvm install 1.8.7 1.9.2 jruby rbx
  #   rvm 1.8.7,1.9.2,jruby,rbx ruby bench/simple.rb

  require 'benchmark'

  ITERS = 100_000

  Benchmark.bmbm do |x|
    x.report 'object creation' do
      ITERS.times do
        Object.new
      end
    end
    x.report 'message creation' do
      ITERS.times do
        MyMessage.new(
          :number => 12345,
          :chars  => 'hello',
          :raw    => 'world',
          :bool   => true,
          :float  => 1.2345
        )
      end
    end
    x.report 'message encoding' do
      m = MyMessage.new(
        :number => 12345,
        :chars  => 'hello',
        :raw    => 'world',
        :bool   => true,
        :float  => 1.2345
      )
      ITERS.times do
        m.encode
      end
    end
    x.report 'message decoding' do
      str = MyMessage.new(
        :number => 12345,
        :chars  => 'hello',
        :raw    => 'world',
        :bool   => true,
        :float  => 1.2345
      ).encode.to_s
      ITERS.times do
        MyMessage.decode(str.dup)
      end
    end
  end

end

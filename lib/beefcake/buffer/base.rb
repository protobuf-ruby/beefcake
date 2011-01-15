module Beefcake

  class Buffer

    MinUint32 =  0
    MaxUint32 =  (1<<32)-1
    MinInt32  = -(1<<31)
    MaxInt32  =  (1<<31)-1

    MinUint64 =  0
    MaxUint64 =  (1<<64)-1
    MinInt64  = -(1<<63)
    MaxInt64  =  (1<<63)-1

    attr_reader :buf

    alias :to_s   :buf
    alias :to_str :buf

    class OutOfRange < StandardError
      def initialize(n)
        super("Value of of range: %d" % [n])
      end
    end

    class BufferOverflow < StandardError
      def initialize(s)
        super("Too many bytes read for %s" % [s])
      end
    end

    def initialize
      clear!
    end

    def clear!
      @buf = ""
    end

    def <<(bytes)
      buf << bytes
    end

    def read(n)
      buf.slice!(0, n)
    end

  end

end

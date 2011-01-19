require 'beefcake/buffer/encode'

class BufferEncodeTest < Test::Unit::TestCase

  B = Beefcake::Buffer

  def setup
    @buf = B.new
  end

  def test_append_info
    @buf.append_info(1, 0)
    assert_equal "\010", @buf.to_s

    @buf.clear!
    @buf.append_info(2, 1)
    assert_equal "\021", @buf.to_s
  end

  def test_append_lendel
    @buf.append_lendel("testing")
    assert_equal "\007testing", @buf.to_s
  end

  def test_append_fixed32
    @buf.append_fixed32(1)
    assert_equal "\001\0\0\0", @buf.to_s

    @buf.clear!
    @buf.append_fixed32(B::MinUint32)
    assert_equal "\0\0\0\0", @buf.to_s

    @buf.clear!
    @buf.append_fixed32(B::MaxUint32)
    assert_equal "\377\377\377\377", @buf.to_s

    assert_raise B::OutOfRange do
      @buf.append_fixed32(B::MinUint32 - 1)
    end

    assert_raise B::OutOfRange do
      @buf.append_fixed32(B::MaxUint32 + 1)
    end
  end

  def test_append_fixed64
    @buf.append_fixed64(1)
    assert_equal "\001\0\0\0\0\0\0\0", @buf.to_s

    @buf.clear!
    @buf.append_fixed64(B::MinUint64)
    assert_equal "\000\0\0\0\0\0\0\0", @buf.to_s

    @buf.clear!
    @buf.append_fixed64(B::MaxUint64)
    assert_equal "\377\377\377\377\377\377\377\377", @buf.to_s

    assert_raise B::OutOfRange do
      @buf.append_fixed64(B::MinUint64 - 1)
    end

    assert_raise B::OutOfRange do
      @buf.append_fixed64(B::MaxUint64 + 1)
    end
  end

  def test_append_uint32
    @buf.append_uint32(1)
    assert_equal "\001", @buf.to_s

    @buf.clear!
    @buf.append_uint32(B::MinUint32)
    assert_equal "\000", @buf.to_s

    @buf.clear!
    @buf.append_uint32(B::MaxUint32)
    assert_equal "\377\377\377\377\017", @buf.to_s

    assert_raise B::OutOfRange do
      @buf.append_uint32(B::MinUint32 - 1)
    end

    assert_raise B::OutOfRange do
      @buf.append_uint32(B::MaxUint32 + 1)
    end
  end

  def test_append_int32
    @buf.append_int32(1)
    assert_equal "\001", @buf.to_s

    @buf.clear!
    @buf.append_int32(-1)
    assert_equal "\377\377\377\377\377\377\377\377\377\001", @buf.to_s

    @buf.clear!
    @buf.append_int32(B::MinInt32)
    assert_equal "\200\200\200\200\370\377\377\377\377\001", @buf.to_s

    @buf.clear!
    @buf.append_int32(B::MaxInt32)
    assert_equal "\377\377\377\377\007", @buf.to_s

    assert_raise B::OutOfRange do
      @buf.append_int32(B::MinInt32 - 1)
    end

    assert_raise B::OutOfRange do
      @buf.append_int32(B::MaxInt32 + 1)
    end
  end

  def test_append_int64
    @buf.append_int64(1)
    assert_equal "\001", @buf.to_s

    @buf.clear!
    @buf.append_int64(-1)
    assert_equal "\377\377\377\377\377\377\377\377\377\001", @buf.to_s

    @buf.clear!
    @buf.append_int64(B::MinInt64)
    assert_equal "\200\200\200\200\200\200\200\200\200\001", @buf.to_s

    @buf.clear!
    @buf.append_int64(B::MaxInt64)
    assert_equal "\377\377\377\377\377\377\377\377\177", @buf.to_s

    assert_raise B::OutOfRange do
      @buf.append_int64(B::MinInt64 - 1)
    end

    assert_raise B::OutOfRange do
      @buf.append_int64(B::MaxInt64 + 1)
    end
  end

  def test_append_uint64
    @buf.append_uint64(1)
    assert_equal "\001", @buf.to_s

    @buf.clear!
    @buf.append_uint64(B::MinUint64)
    assert_equal "\000", @buf.to_s

    @buf.clear!
    @buf.append_uint64(B::MaxUint64)
    assert_equal "\377\377\377\377\377\377\377\377\377\001", @buf.to_s

    assert_raise B::OutOfRange do
      @buf.append_uint64(B::MinUint64 - 1)
    end

    assert_raise B::OutOfRange do
      @buf.append_uint64(B::MaxUint64 + 1)
    end
  end

  def test_append_float
    @buf.clear!
    @buf.append_float(3.14)
    assert_equal "\303\365H@", @buf.to_s
  end

  def test_append_double
    @buf.clear!
    @buf.append_float(Math::PI)
    assert_equal "\333\017I@", @buf.to_s
  end

  def test_append_bool
    @buf.append_bool(true)
    @buf.append_bool(false)
    assert_equal "\001\000", @buf.to_s
  end

end

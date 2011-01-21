require 'beefcake/buffer'

class BufferDecodeTest < Test::Unit::TestCase

  B = Beefcake::Buffer

  def setup
    @buf = B.new
  end

  def test_read_info
    @buf.append_info(1, 2)
    assert_equal [1, 2], @buf.read_info

    @buf.append_info(2, 5)
    assert_equal [2, 5], @buf.read_info
  end

  def test_read_string
    @buf.append_string("testing")
    assert_equal "testing", @buf.read_string
  end

  def test_read_fixed32
    @buf.append_fixed32(123)
    assert_equal 123, @buf.read_fixed32
  end

  def test_read_fixed64
    @buf.append_fixed64(456)
    assert_equal 456, @buf.read_fixed64
  end

  def test_read_uint32
    @buf.append_uint32(1)
    assert_equal 1, @buf.read_uint32
  end

  def test_read_int32
    @buf.append_int32(999)
    assert_equal 999, @buf.read_int32

    @buf.append_int32(-999)
    assert_equal -999, @buf.read_int32
  end

  def test_read_int64
    @buf.append_int64(999)
    assert_equal 999, @buf.read_int64

    @buf.append_int64(-999)
    assert_equal -999, @buf.read_int64
  end

  def test_read_uint64
    @buf.append_uint64(1)
    assert_equal 1, @buf.read_uint64
  end

  def test_read_float
    @buf.append_float(0.5)
    assert_equal 0.5, @buf.read_float
  end

  def test_read_double
    @buf.append_double(Math::PI)
    assert_equal Math::PI, @buf.read_double
  end

  def test_read_bool
    @buf.append_bool(true)
    assert_equal true, @buf.read_bool

    @buf.append_bool(false)
    assert_equal false, @buf.read_bool
  end

  def test_read_sint32
    @buf.append_sint32(B::MinInt32)
    assert_equal B::MinInt32, @buf.read_sint32

    @buf.buf = ""
    @buf.append_sint32(B::MaxInt32)
    assert_equal B::MaxInt32, @buf.read_sint32
  end

  def test_read_sfixed32
    @buf.append_sfixed32(B::MinInt32)
    assert_equal B::MinInt32, @buf.read_sfixed32

    @buf.buf = ""
    @buf.append_sfixed32(B::MaxInt32)
    assert_equal B::MaxInt32, @buf.read_sfixed32
  end

  def test_read_sint64
    @buf.append_sint64(B::MinInt64)
    assert_equal B::MinInt64, @buf.read_sint64

    @buf.buf = ""
    @buf.append_sint64(B::MaxInt64)
    assert_equal B::MaxInt64, @buf.read_sint64
  end

  def test_read_sfixed64
    @buf.append_sfixed64(B::MinInt64)
    assert_equal B::MinInt64, @buf.read_sfixed64

    @buf.buf = ""
    @buf.append_sfixed64(B::MaxInt64)
    assert_equal B::MaxInt64, @buf.read_sfixed64
  end

end

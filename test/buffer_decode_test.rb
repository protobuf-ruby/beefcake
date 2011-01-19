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

  def test_read_varint32
    @buf.append_varint32(999)
    assert_equal 999, @buf.read_varint32

    @buf.append_varint32(-999)
    assert_equal -999, @buf.read_varint32
  end

  def test_read_varint64
    @buf.append_varint64(999)
    assert_equal 999, @buf.read_varint64

    @buf.append_varint64(-999)
    assert_equal -999, @buf.read_varint64
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

end

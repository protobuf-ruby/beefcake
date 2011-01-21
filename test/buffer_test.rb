require 'beefcake/buffer'

class BufferTest < Test::Unit::TestCase

  def setup
    @buf = Beefcake::Buffer.new
  end

  def test_simple
    assert_equal "", @buf.to_s

    @buf << "asdf"
    assert_equal "asdf", @buf.to_s
    assert_equal "asdf", @buf.to_str

    @buf.buf = ""
    assert_equal "", @buf.to_s
  end

  def test_wire_for
    assert_equal 0, Beefcake::Buffer.wire_for(:int32)
    assert_equal 0, Beefcake::Buffer.wire_for(:uint32)
    assert_equal 0, Beefcake::Buffer.wire_for(:sint32)
    assert_equal 0, Beefcake::Buffer.wire_for(:int64)
    assert_equal 0, Beefcake::Buffer.wire_for(:uint64)
    assert_equal 0, Beefcake::Buffer.wire_for(:sint64)

    assert_equal 1, Beefcake::Buffer.wire_for(:fixed64)
    assert_equal 1, Beefcake::Buffer.wire_for(:sfixed64)
    assert_equal 1, Beefcake::Buffer.wire_for(:double)

    assert_equal 2, Beefcake::Buffer.wire_for(:string)
    assert_equal 2, Beefcake::Buffer.wire_for(:bytes)

    assert_equal 5, Beefcake::Buffer.wire_for(:fixed32)
    assert_equal 5, Beefcake::Buffer.wire_for(:sfixed32)
    assert_equal 5, Beefcake::Buffer.wire_for(:float)

    assert_raises Beefcake::Buffer::UnknownType do
      Beefcake::Buffer.wire_for(:asdf)
    end
  end

end

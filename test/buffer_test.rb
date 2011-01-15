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

    @buf.clear!
    assert_equal "", @buf.to_s
  end

end

require 'beefcake/decode'
require 'beefcake/encode'

class DecodeTest < Test::Unit::TestCase
  include Beefcake::Decode
  include Beefcake::Encode

  def e(v, type, fn=1)
    encode!("", v, type, fn)
  end

  def test_int32
    assert_equal [1, 0], decode!(e(0, :int32), :int32)
    assert_equal [1, 1], decode!(e(1, :int32), :int32)
    assert_equal [1, 2], decode!(e(2, :int32), :int32)
  end

  def test_int64
    assert_equal [1, 0], decode!(e(0, :int64), :int64)
    assert_equal [1, 1], decode!(e(1, :int64), :int64)
    assert_equal [1, 2], decode!(e(2, :int64), :int64)
  end

  def test_signed32
    assert_equal [1,  0], decode!(e(0,  :sint32), :sint32)
    assert_equal [1, -1], decode!(e(-1, :sint32), :sint32)
    assert_equal [1,  1], decode!(e(1,  :sint32), :sint32)
  end

  def test_fixed32
    assert_equal [1, 0], decode!(e(0, :fixed32), :fixed32)
    assert_equal [1, 1], decode!(e(1, :fixed32), :fixed32)
    assert_equal [1, 2], decode!(e(2, :fixed32), :fixed32)
  end

  def test_sfixed32
    assert_equal [1,  0], decode!(e(0,  :sfixed32), :sfixed32)
    assert_equal [1, -1], decode!(e(-1, :sfixed32), :sfixed32)
    assert_equal [1,  1], decode!(e(1,  :sfixed32), :sfixed32)
  end

  def xtest_float
  end

  def xtest_signed64
  end

  def xtest_fixed64
  end

  def xtest_sfixed64
  end

  def xtest_double
  end

  def xteststring
  end

  def xtest_enum
  end

  ##
  # Test encoding of multiple fields
  def xtest_decode
    obj = { :a => "test", :b => "test" }

    flds = [
      [:required, :a, :int32,  1],
      [:required, :b, :string, 2]
    ]

    encoded = encode("", obj, flds)
    assert_equal nil, decode
  end

  def xtest_encode_required_but_nil
    flds = [
      [:required, :a, :int32,  1],
    ]

    assert_raise Beefcake::MissingField do
      decode("", {}, flds)
    end
  end
end

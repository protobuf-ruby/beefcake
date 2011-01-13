require 'beefcake/encode'

class EncodeTest < Test::Unit::TestCase
  include Beefcake::Encode

  def test_int32
    assert_equal "\010\000", encode!("", 0, :int32, 1)
    assert_equal "\010\001", encode!("", 1, :int32, 1)
    assert_equal "\010\001", encode!("", 1, :uint32, 1)
  end

  def test_int64
    assert_equal "\010\000", encode!("", 0, :int64, 1)
    assert_equal "\010\001", encode!("", 1, :int64, 1)
    assert_equal "\010\001", encode!("", 1, :uint64, 1)
  end

  def test_signed32
    assert_equal "\010\000", encode!("", 0,  :sint32, 1)
    assert_equal "\010\001", encode!("", -1, :sint32, 1)
    assert_equal "\010\002", encode!("", 1,  :sint32, 1)
  end

  def test_fixed32
    assert_equal "\015\000\000\000\000", encode!("", 0, :fixed32, 1)
    assert_equal "\015\001\000\000\000", encode!("", 1, :fixed32, 1)
  end

  def test_sfixed32
    assert_equal "\015\000\000\000\000", encode!("", 0,  :sfixed32, 1)
    assert_equal "\015\001\000\000\000", encode!("", -1, :sfixed32, 1)
    assert_equal "\015\002\000\000\000", encode!("", 1,  :sfixed32, 1)
  end

  def test_float
    assert_equal "\015\000\000\000\000", encode!("", 0.0, :float, 1)
    assert_equal "\r\303\365H@", encode!("", 3.14, :float, 1)
  end

  def test_signed64
    assert_equal "\010\000", encode!("", 0,  :sint64, 1)
    assert_equal "\010\001", encode!("", -1, :sint64, 1)
    assert_equal "\010\002", encode!("", 1,  :sint64, 1)
  end

  def test_fixed64
    assert_equal "\011\000\000\000\000\000\000\000\000", encode!("", 0, :fixed64, 1)
    assert_equal "\011\001\000\000\000\000\000\000\000", encode!("", 1, :fixed64, 1)
    assert_equal "\011\002\000\000\000\000\000\000\000", encode!("", 2, :fixed64, 1)
  end

  def test_sfixed64
    assert_equal "\011\000\000\000\000\000\000\000\000", encode!("", 0,  :sfixed64, 1)
    assert_equal "\011\001\000\000\000\000\000\000\000", encode!("", -1, :sfixed64, 1)
    assert_equal "\011\002\000\000\000\000\000\000\000", encode!("", 1,  :sfixed64, 1)
  end

  def test_double
    assert_equal "\011\030-DT\373!\t@", encode!("", Math::PI, :double, 1)
  end

  def test_string
    assert_equal "\022\007testing", encode!("", "testing", :string, 2)
  end

  def test_enum
    assert_equal "\010\001", encode!("", 1, Module.new, 1)
  end

  ##
  # Test encoding of multiple fields
  def test_encode
    obj = {
      :a => 1,
      :b => "testing"
    }

    flds = [
      [:required, :a, :int32,  1],
      [:required, :b, :string, 2]
    ]

    assert_equal "\010\001\022\007testing", encode("", obj, flds)
  end

  def test_encode_required_but_nil
    flds = [
      [:required, :a, :int32,  1],
    ]

    assert_raise Beefcake::MissingField do
      encode("", {}, flds)
    end
  end
end

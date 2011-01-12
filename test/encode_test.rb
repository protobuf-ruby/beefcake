require 'beefcake/encode'

class EncodeTest < Test::Unit::TestCase
  include Beefcake::Encode

  def test_encode_field
    assert_equal "\010\001", encode!("", 1, :int32, 1)
    assert_equal "\022\007testing", encode!("", "testing", :string, 2)
  end

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

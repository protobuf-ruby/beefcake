require 'beefcake/lendel'

class LendelTest < Test::Unit::TestCase
  def e(*v)
    Beefcake::Lendel.encode("", *v)
  end

  def d(r)
    Beefcake::Lendel.decode(r)
  end

  def test_encode_simple
    assert_equal "\007testing", e("testing")
  end

  def test_encodable
    encodable = "encodable"
    def encodable.encode(w)
      w << self
    end

    assert_equal "\011encodable", e(encodable)
  end

  def test_decode_simple
    assert_equal "", d(e(""))
    assert_equal "testing", d(e("testing"))
  end
end

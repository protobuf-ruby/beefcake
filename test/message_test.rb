require 'beefcake'

class EmbedMe < Beefcake::Message
  required :x, :string, 1
end

class SimpleMessage < Beefcake::Message
  # Fields are sotred by `fn` for encoding.
  # It's probably uncommon to have an optional
  # field set before a required.  But it makes
  # testing for errors easier.
  optional :a, :string, 1
  required :b, :int32,  2
  optional :e, EmbedMe, 3
end

class MessageTest < Test::Unit::TestCase
  def test_encode
    msg = SimpleMessage.new :a => "testing", :b => 2
    assert_equal "\012\007testing\020\002", msg.encode
  end

  def test_encode_null_optional
    msg = SimpleMessage.new :b => 1
    assert_equal "\020\001", msg.encode
  end

  def test_upgrade
    msg = SimpleMessage.new :b => 1
    w   = ""

    msg.encode(w)
    assert_equal "\020\001", w

    msg.upgrade(w, :b, 2)
    assert_equal "\020\001\020\002", w
  end

  def test_upgrade_null_value
    msg = SimpleMessage.new :b => 1
    w   = ""

    msg.encode(w)
    assert_equal "\020\001", w

    msg.upgrade(w, :b, nil)
    assert_equal "\020\001", w
  end

  def test_upgrade_unknown_field
    msg = SimpleMessage.new :b => 1
    assert_raise NoMethodError do
      msg.upgrade("", :x, 1)
    end
  end

  def test_encode_null_required
    msg = SimpleMessage.new :a => "testing"
    encoded = ""
    assert_raise Beefcake::MissingField do
      msg.encode(encoded)
    end
    assert_equal "", encoded
  end

  def test_encode_embeded_message
    msg = SimpleMessage.new(
      :b => 1, # required
      :e => EmbedMe.new(:x => "test")
    )
    assert_equal "\020\001\032\006\n\004test", msg.encode
  end

end

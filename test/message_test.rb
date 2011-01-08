require 'beefcake/message'

class SimpleMessage < Beefcake::Message
  optional :a, :string, 1
  optional :b, :int32,  2
end


class MessageTest < Test::Unit::TestCase

  def test_encode
    msg = SimpleMessage.new :a => "testing", :b => 2
    assert_equal "\012\007testing\020\002", msg.encode("")
  end

  def test_decode
    msg = SimpleMessage.new :a => "testing", :b => 2
    encoded = msg.encode("")
    decoded = SimpleMessage.decode(encoded)

    assert_equal msg.a, decoded.a
    assert_equal msg.b, decoded.b
  end
end

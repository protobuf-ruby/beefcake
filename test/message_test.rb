require 'beefcake'

class NumericsMessage
  include Beefcake::Message

  required :int32,    :int32,    1
  required :uint32,   :uint32,   2
  required :sint32,   :sint32,   3
  required :fixed32,  :fixed32,  4
  required :sfixed32, :sfixed32, 5

  required :int64,    :int64,    6
  required :uint64,   :uint64,   7
  required :sint64,   :sint64,   8
  required :fixed64,  :fixed64,  9
  required :sfixed64, :sfixed64, 10
end


class LendelsMessage
  include Beefcake::Message

  required :string, :string, 1
  required :bytes,  :bytes,  2
end


class SimpleMessage
  include Beefcake::Message

  required :a, :int32, 1
end


class CompositeMessage
  include Beefcake::Message

  required :encodable, SimpleMessage, 1
end


class EnumsMessage
  include Beefcake::Message

  module X
    A = 1
  end

  required :a, X, 1
end


class EnumsDefaultMessage
  include Beefcake::Message

  module X
    A = 1
    B = 2
  end

  required :a, X, 1, :default => X::B
end


class RepeatedMessage
  include Beefcake::Message

  repeated :a, :int32, 1
end


class MessageTest < Test::Unit::TestCase
  B = Beefcake::Buffer

  ## Encoding
  def test_encode_numerics
    buf = Beefcake::Buffer.new

    buf.append_tagged_int32      1, B::MaxInt32
    buf.append_tagged_uint32     2, B::MaxUint32
    buf.append_tagged_sint32     3, B::MinInt32
    buf.append_tagged_fixed32    4, B::MaxInt32
    buf.append_tagged_sfixed32   5, B::MinInt32
    buf.append_tagged_int64      6, B::MaxInt64
    buf.append_tagged_uint64     7, B::MaxUint64
    buf.append_tagged_sint64     8, B::MinInt64
    buf.append_tagged_fixed64    9, B::MaxInt64
    buf.append_tagged_sfixed64  10, B::MinInt64

    msg = NumericsMessage.new({
      :int32     => B::MaxInt32,
      :uint32    => B::MaxUint32,
      :sint32    => B::MinInt32,
      :fixed32   => B::MaxInt32,
      :sfixed32  => B::MinInt32,

      :int64     => B::MaxInt64,
      :uint64    => B::MaxUint64,
      :sint64    => B::MinInt64,
      :fixed64   => B::MaxInt64,
      :sfixed64  => B::MinInt64
    })

    assert_equal buf.to_s, msg.encode.to_s
  end

  def test_encode_lendels
    buf = Beefcake::Buffer.new

    buf.append_tagged_string 1, "testing"
    buf.append_tagged_bytes  2, "unixisawesome"

    msg = LendelsMessage.new({
      :string => "testing",
      :bytes  => "unixisawesome"
    })

    assert_equal buf.to_s, msg.encode.to_s
  end

  def test_encode_lendel_composite
    buf1 = Beefcake::Buffer.new
    buf1.append_tagged_int32 1, 123

    buf2 = Beefcake::Buffer.new
    buf2.append_tagged_string 1, buf1

    msg = CompositeMessage.new(
      :encodable => SimpleMessage.new(:a => 123)
    )

    assert_equal buf2.to_s, msg.encode.to_s
  end

  def test_encode_to_string
    msg = SimpleMessage.new :a => 123
    str = ""
    msg.encode(str)
    assert_equal "\b{", str
  end

  def test_encode_enum
    buf = Beefcake::Buffer.new
    buf.append_tagged_int32 1, 2

    msg = EnumsMessage.new :a => EnumsMessage::X::A
    assert_equal "\b\001", msg.encode.to_s
  end

  def test_encode_invalid_enum_value
    assert_raise Beefcake::Message::InvalidValue do
      EnumsMessage.new(:a => 99).encode
    end
  end

  def test_encode_unset_required_field
    assert_raise Beefcake::Message::RequiredFieldNotSetError do
      SimpleMessage.new.encode
    end
  end

  def test_encode_repeated_field
    buf = Beefcake::Buffer.new

    buf.append_tagged_int32 1, 1
    buf.append_tagged_int32 1, 2
    buf.append_tagged_int32 1, 3
    buf.append_tagged_int32 1, 4
    buf.append_tagged_int32 1, 5

    msg = RepeatedMessage.new :a => [1, 2, 3, 4, 5]

    assert_equal buf.to_s, msg.encode.to_s
  end

  def test_encode_packed_repeated_field
    #fail "TODO"
  end


  ## Decoding
  def test_wire_does_not_match_decoded_info
    #fail "TODO"
  end

  def test_decode_unset_required_field
    #fail "TODO"
  end

  def test_decode_unknown_field_number
    #fail "TODO"
  end

  def test_decode_merge
    #fail "TODO"
  end

end

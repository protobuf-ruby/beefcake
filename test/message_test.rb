require 'minitest/autorun'
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

  optional :a, :int32,  1
  optional :b, :string, 2
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

  optional :a, X, 1, :default => X::B
end


class RepeatedMessage
  include Beefcake::Message

  repeated :a, :int32, 1
end


class PackedRepeatedMessage
  include Beefcake::Message

  repeated :a, :int32, 1, :packed => true
end

class RepeatedNestedMessage
  include Beefcake::Message

  repeated :simple, SimpleMessage, 1
end

class BoolMessage
  include Beefcake::Message

  required :bool, :bool, 1
end

class LargeFieldNumberMessage
  include Beefcake::Message

  required :field_1, :string, 1
  required :field_2, :string, 100
end

class FieldsMessage
  include Beefcake::Message

  repeated :fields, :string, 1
end

class FieldTest < Minitest::Test
  FIELD = Beefcake::Message::Field

  def test_required?
    f = FIELD.new :required, :field1, :string, 1
    assert f.required?
    refute f.optional?
    refute f.repeated?

    f = FIELD.new :optional, :field1, :int32, 1
    refute f.required?

    f = FIELD.new :repeated, :field1, :int32, 1
    refute f.required?
  end

  def test_optional?
    f = FIELD.new :optional, :field1, :string, 1
    assert f.optional?
    refute f.required?
    refute f.repeated?

    f = FIELD.new :required, :field1, :int32, 1
    refute f.optional?

    f = FIELD.new :repeated, :field1, :int32, 1
    refute f.optional?
  end

  def test_repeated?
    f = FIELD.new :repeated, :field1, :string, 1
    assert f.repeated?
    refute f.required?
    refute f.optional?

    f = FIELD.new :optional, :field1, :int32, 1
    refute f.repeated?

    f = FIELD.new :required, :field1, :int32, 1
    refute f.optional?
  end

  def test_same_type
    f = FIELD.new(:required, :field1, :int32, 1)
    assert f.same_type?(:int32)
    refute f.same_type?(:int64)
    refute f.same_type?(SimpleMessage)

    f = FIELD.new(:required, :field1, SimpleMessage, 1)
    assert f.same_type?(SimpleMessage)
    refute f.same_type?(:int32)
    refute f.same_type?(:string)
    refute f.same_type?(NumericsMessage)
  end

  def test_is_protobuf?
    f = FIELD.new(:required, :field1, SimpleMessage, 1)
    assert f.is_protobuf?

    f = FIELD.new(:required, :field1, :string, 1)
    refute f.is_protobuf?
  end
end

class MessageTest < Minitest::Test
  B = Beefcake::Buffer

  ## Encoding
  def test_encode_numerics
    buf = Beefcake::Buffer.new

    buf.append(:int32, B::MaxInt32, 1)
    buf.append(:uint32, B::MaxUint32, 2)
    buf.append(:sint32, B::MinInt32, 3)
    buf.append(:fixed32, B::MaxInt32, 4)
    buf.append(:sfixed32, B::MinInt32, 5)
    buf.append(:int64, B::MaxInt64, 6)
    buf.append(:uint64, B::MaxUint64, 7)
    buf.append(:sint64, B::MinInt64, 8)
    buf.append(:fixed64, B::MaxInt64, 9)
    buf.append(:sfixed64, B::MinInt64, 10)

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

  def test_encode_strings
    buf = Beefcake::Buffer.new

    buf.append(:string, "test\ning", 1)
    buf.append(:bytes, "unixisawesome", 2)

    msg = LendelsMessage.new({
      :string => "test\ning",
      :bytes  => "unixisawesome"
    })

    assert_equal buf.to_s, msg.encode.to_s
  end

  def test_encode_string_composite
    buf1 = Beefcake::Buffer.new
    buf1.append(:int32, 123, 1)

    buf2 = Beefcake::Buffer.new
    buf2.append(:string, buf1, 1)

    msg = CompositeMessage.new(
      :encodable => SimpleMessage.new(:a => 123)
    )

    assert_equal buf2.to_s, msg.encode.to_s

    msg = CompositeMessage.new(
        :encodable => {:a => 123}
    )
    assert_equal buf2.to_s, msg.encode.to_s

  end

  def test_encode_to_string
    msg = SimpleMessage.new :a => 123
    str = ""
    msg.encode(str)
    assert_equal "\b{", str
  end

  def test_delimited_end_to_end
    msg = SimpleMessage.new :a => 123, :b => "hi mom!"
    str = ""

    1000.times do
      msg.write_delimited(str)
    end

    1000.times do
      dec = SimpleMessage.read_delimited(str)
      assert_equal msg, dec
    end
  end

  def test_empty_buffer_delimited_read
    assert_equal SimpleMessage.read_delimited(""), nil
  end

  def test_encode_enum
    buf = Beefcake::Buffer.new
    buf.append(:int32, 2, 1)

    msg = EnumsMessage.new :a => EnumsMessage::X::A
    assert_equal "\b\001", msg.encode.to_s

    msg = EnumsMessage.new :a => 1
    assert_equal "\b\001", msg.encode.to_s
  end

  def test_encode_invalid_enum_value
    assert_raises Beefcake::Message::InvalidValueError do
      EnumsMessage.new(:a => 99).encode
    end
  end

  def test_encode_unset_required_field
    assert_raises Beefcake::Message::RequiredFieldNotSetError do
      NumericsMessage.new.encode
    end
  end

  def test_decode_required_bool
    msg = BoolMessage.new :bool => false
    enc = msg.encode
    dec = BoolMessage.decode(enc)
    assert_equal false, dec.bool
  end

  def test_encode_repeated_field
    buf = Beefcake::Buffer.new

    buf.append(:int32, 1, 1)
    buf.append(:int32, 2, 1)
    buf.append(:int32, 3, 1)
    buf.append(:int32, 4, 1)
    buf.append(:int32, 5, 1)

    msg = RepeatedMessage.new :a => [1, 2, 3, 4, 5]

    assert_equal buf.to_s, msg.encode.to_s
  end

  def test_encode_packed_repeated_field
    buf = Beefcake::Buffer.new

    # Varint
    buf.append_info(1, 0)

    # Give size in bytes
    buf.append_uint64 5

    # Values
    buf.append_int32 1
    buf.append_int32 2
    buf.append_int32 3
    buf.append_int32 4
    buf.append_int32 5

    msg = PackedRepeatedMessage.new :a => [1, 2, 3, 4, 5]

    assert_equal buf.to_s, msg.encode.to_s
  end

  def test_encode_large_field_number
    buf = Beefcake::Buffer.new
    buf.append(:string, "abc", 1)
    buf.append(:string, "123", 100)

    msg = LargeFieldNumberMessage.new
    msg.field_1 = "abc"
    msg.field_2 = "123"

    assert_equal buf.to_s, msg.encode.to_s
  end

  def test_encode_unknown_field
    msg = SimpleMessage.new :mystery_field => 'asdf'
    msg.encode.to_s
  end

  ## Decoding
  def test_decode_numerics
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

    got = NumericsMessage.decode(msg.encode)

    msg.__beefcake_fields__.values.each do |fld|
      assert_equal msg[fld.name], got[fld.name], fld.name
    end
  end

  def test_wire_does_not_match_decoded_info
    buf = Beefcake::Buffer.new
    buf.append(:string, "testing", 1)

    assert_raises Beefcake::Message::WrongTypeError do
      SimpleMessage.decode(buf)
    end
  end

  def test_decode_unknown_field_number
    buf = Beefcake::Buffer.new
    buf.append(:string, "testing", 2)

    msg = SimpleMessage.decode(buf)

    assert_equal nil, msg.a
  end

  def test_decode_repeated_field
    msg = RepeatedMessage.new :a => [1, 2, 3, 4, 5]
    got = RepeatedMessage.decode(msg.encode)

    assert_equal msg.a, got.a
  end

  def test_decode_packed_repeated_field
    msg = PackedRepeatedMessage.new :a => [1, 2, 3, 4, 5]
    got = PackedRepeatedMessage.decode(msg.encode)

    assert_equal msg.a, got.a
  end

  def test_decode_merge
    a = SimpleMessage.new :a => 1
    b = SimpleMessage.new :a => 2

    x = SimpleMessage.decode(a.encode)
    SimpleMessage.decode(b.encode, x)

    assert_equal b.a, x.a
  end

  def test_decode_default
    got = EnumsDefaultMessage.decode("")
    assert_equal EnumsDefaultMessage.fields[1].opts[:default], got.a
  end

  def test_decode_unset_required_fields
    assert_raises Beefcake::Message::RequiredFieldNotSetError do
      NumericsMessage.decode("")
    end
  end

  def test_decode_enum
    msg = EnumsMessage.new(:a => 1).encode
    got = EnumsMessage.decode(msg)
    assert_equal 1, got.a
  end

  def test_decode_repeated_nested
    simple = [
      SimpleMessage.new(:a => 1),
      SimpleMessage.new(:b => "hello")
    ]
    msg = RepeatedNestedMessage.new(:simple => simple).encode
    got = RepeatedNestedMessage.decode(msg)
    assert_equal 2, got.simple.size
    assert_equal 1, got.simple[0].a
    assert_equal "hello", got.simple[1].b

    simple_pure = [
      {:a => 1},
      {:b => "hello"}
    ]
    msg = RepeatedNestedMessage.new(:simple => simple_pure).encode
    got = RepeatedNestedMessage.decode(msg)
    assert_equal 2, got.simple.size
    assert_equal 1, got.simple[0].a
    assert_equal "hello", got.simple[1].b
  end

  def test_equality
    a = SimpleMessage.new :a => 1
    b = SimpleMessage.new :a => 1
    assert_equal a, b
    c = SimpleMessage.new :a => 2
    refute_equal b, c

    d = EnumsMessage.new :a => 5
    e = EnumsDefaultMessage.new :a => 5

    refute_equal d, e
    refute_equal d, :symbol
    refute_equal :symbol, d
  end

  def test_inspect
    msg = SimpleMessage.new :a => 1
    assert_equal "<SimpleMessage a: 1>", msg.inspect
    msg.b = "testing"
    assert_equal "<SimpleMessage a: 1, b: \"testing\">", msg.inspect
    msg.a = nil
    assert_equal "<SimpleMessage b: \"testing\">", msg.inspect
  end

  def test_inspect_enums
    msg = EnumsMessage.new :a => 1
    assert_equal "<EnumsMessage a: A(1)>", msg.inspect
    msg.a = 2
    assert_equal "<EnumsMessage a: -NA-(2)>", msg.inspect
  end

  def test_inspect_nested_types
    msg = CompositeMessage.new(:encodable => SimpleMessage.new(:a => 1))
    assert_equal "<CompositeMessage encodable: <SimpleMessage a: 1>>", msg.inspect
  end

  def test_decode_nested_types
    msg = CompositeMessage.new(:encodable => SimpleMessage.new(:a => 1))
    enc = msg.encode
    dec = CompositeMessage.decode(enc)
    assert_equal "<CompositeMessage encodable: <SimpleMessage a: 1>>", dec.inspect
  end

  def test_to_hash
    msg =  SimpleMessage.new :a => 1
    exp = { :a => 1 }
    assert_equal exp, msg.to_hash

    msg = RepeatedNestedMessage.new(
      :simple => [
        SimpleMessage.new(:a => 1),
        SimpleMessage.new(:b => 'abc dfg'),
        SimpleMessage.new(:a => 2, :b => 'ijk lmn')
      ]
    )
    exp = {
      :simple =>[
        {:a => 1},
        {:b => 'abc dfg'},
        {:a => 2, :b => 'ijk lmn'}
      ]
    }
    assert_equal exp, msg.to_hash
  end

  def test_duplicate_index
    assert_raises Beefcake::Message::DuplicateFieldNumber do
      Class.new do
        include Beefcake::Message

        required :clever_name, :int32, 1
        required :naughty_field, :string, 1
      end
    end
  end

  def test_bool_to_hash
    true_message = BoolMessage.new :bool => true
    true_expectation = { :bool => true }
    assert_equal true_expectation, true_message.to_hash

    false_message = BoolMessage.new :bool => false
    false_expectation = { :bool => false }
    assert_equal false_expectation, false_message.to_hash
  end

  def test_fields_named_fields
    contents = %w{fields named fields}
    msg = FieldsMessage.new fields: contents
    assert_equal 1, msg.__beefcake_fields__.length
    assert_equal contents, msg.fields

    assert_equal msg, FieldsMessage.decode(msg.encode)

    assert_equal "<FieldsMessage fields: [\"fields\", \"named\", \"fields\"]>", msg.inspect
  end
end

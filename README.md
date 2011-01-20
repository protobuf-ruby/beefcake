# Beefcake (A sane Google Protocol Buffers library for Ruby)
## It's all about being Buf; ProtoBuf.

## NOTICE:  This project is still a moving target.  Decoding
##          will be brought back tomorrow (1/12/2011).

# Example

    require 'beefcake'

    class Point
      includ Beefcake::Message

      required :x, :int32, 1
      required :y, :int32, 2
      optional :tag, :string, 3
    end

    point = Point.new :x => 1, :y => 2
    # or
    point = Point.new
    point.x = 1
    point.y = 2

## Encoding

Any object responding to `<<` can accept encoding

    s = ""
    point.encode(s)
    p [:s, s]
    # or (because encode returns the string/stream)
    p [:s, point.encode]
    # or
    open("point.dat") do |f|
      point.encode(f)
    end

    # decode
    encoded = point.encode
    decoded = Point.decode(encoded)
    p [:point, decoded]

# Why?

  Ruby deserves and needs first-class ProtoBuf support.
  Other libs didn't feel very "Ruby" to me and were hard to parse.

# Caveats

  Currently Beefcake doesn't parse `.proto` files.  This is OK for now.
  In the simple case, you can create message types by hand; This is Ruby
  after all.

  Example (for the above):

    message Point {
      required int32 x = 1
      required int32 y = 2
      optional string tag = 3
    }

  In the near future, a generator would be nice.  I welcome anyone willing
  to work on it to submit patches.  The other ruby libs lacked things I would
  like, such as an optional namespace param rather than installing on (main).

  This library was built with EventMachine in mind.  Not just blocking-IO.

# Dev

Source:

    $ git clone git://github.com/bmizerany/beefcake

Testing:

    $ gem install turn
    $ cd /path/to/beefcake
    $ turn

# TODO

Very, very near future:

* Enum support
* Wire types 1,3 & 5

Nice to have:

* `.proto` -> Ruby generator
* Groups (would be nice for accessing older protos)
* Remove need to encode embeded messages before writing to the wire.

# Further Reading

http://code.google.com/apis/protocolbuffers/docs/encoding.html

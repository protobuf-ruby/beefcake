module Beefcake
  class UnknownWireType < StandardError
  end

  class UnknownType < StandardError
  end

  class MissingField < StandardError
    def initialize(name)
      super("Field not set: name:#{name}")
    end
  end
end

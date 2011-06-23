# serialize the data with padding
class RightAws::ActiveSdb
  class IntegerSerialization
    class << self
      def serialize(int)
        str = int.to_s
        str = str.rjust(12, '0')
        str
      end

      def deserialize(string)
        string.to_i
      end
    end
  end
end


class Hash
  # A method to recursively symbolize all keys in the Hash class
  def recursively_symbolize_keys!
    self.symbolize_keys!
    self.values.each do |v|
      if v.is_a? Hash
        v.recursively_symbolize_keys!
      elsif v.is_a? Array
        #v.recursively_symbolize_keys!
      end
    end
    self
  end

  def symbolize_keys!
    keys.each do |key|
      self[(key.to_sym rescue key) || key] = delete(key)
    end
    self
  end
end

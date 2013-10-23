module JsonSchemaSpec
  module Util
    class <<self
      def deep_dup(hash)
        duplicate = hash.dup
        duplicate.each_pair do |k,v|
          tv = duplicate[k]
          duplicate[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? deep_dup(tv) : v
        end
        duplicate
      end

      def deep_merge(hash, other_hash)
        other_hash.each_pair do |k,v|
          tv = hash[k]
          hash[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? deep_merge(tv, v) : v
        end
        hash
      end
      
      def mattr_reader(klass, *syms)
        syms.each do |sym|
          raise NameError.new('invalid attribute name') unless sym =~ /^[_A-Za-z]\w*$/
          klass.class_eval(<<-EOS, __FILE__, __LINE__ + 1)
            @@#{sym} = nil unless defined? @@#{sym}

            def self.#{sym}
              @@#{sym}
            end
          EOS
        end
      end

      def mattr_writer(klass, *syms)
        syms.each do |sym|
          raise NameError.new('invalid attribute name') unless sym =~ /^[_A-Za-z]\w*$/
          klass.class_eval(<<-EOS, __FILE__, __LINE__ + 1)
            def self.#{sym}=(obj)
              @@#{sym} = obj
            end
          EOS
        end
      end

      def mattr_accessor(klass, *syms)
        mattr_reader(*syms)
        mattr_writer(*syms)
      end
      
      def symbolize_keys(hash)
        hash.inject({}) do |memo, (key, value)|
          key       = (key.to_sym rescue key) || key
          value     = symbolize_keys(value)   if value.is_a?(Hash)
          memo[key] = value
          memo
        end
      end
    end
  end
end
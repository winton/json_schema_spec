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

      def deep_merge(value, other_value)
        if value.is_a?(Hash) && other_value.is_a?(Hash)
          other_value.each_pair do |k, v|
            value[k] = deep_merge(value[k], v)
          end
        
        elsif value.is_a?(Array) && other_value.is_a?(Array)
          value = (0..([ value.length, other_value.length ].max - 1)).collect do |i|
            deep_merge(value[i], other_value[i])
          end

        elsif other_value

          value = other_value
        end

        value
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
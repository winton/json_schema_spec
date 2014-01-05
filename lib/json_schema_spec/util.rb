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

      def stringify_keys(value)
        work_on_keys(value) { |k| k.to_s }
      end
      
      def symbolize_keys(value)
        work_on_keys(value) { |k| k.to_sym }
      end

      def work_on_keys(value, &block)
        if value.is_a?(Array)
          value.collect { |v| work_on_keys(v, &block) }

        elsif value.is_a?(Hash)
          value.inject({}) do |memo, (k, v)|
            k = (yield(k) rescue k) || k
            v = work_on_keys(v, &block)
            
            memo[k] = v
            memo
          end

        else value
        end
      end
    end
  end
end
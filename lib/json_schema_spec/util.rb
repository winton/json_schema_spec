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
          if tv.is_a?(Hash) && v.is_a?(Hash)
            hash[k] = deep_merge(tv, v)
          elsif  tv.is_a?(Array) && v.is_a?(Array)
            (0..([ tv.length, v.length ].max - 1)).each do |i|
              tv[i] = deep_merge(tv[i], v[i])
            end
            hash[k] = tv
          else
            hash[k] = v
          end
        end
        hash
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
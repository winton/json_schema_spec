require "json"
require "open-uri"
require "yaml"

$:.unshift File.dirname(__FILE__)

require "json_schema_spec/tasks"
require "json_schema_spec/util"

module JsonSchemaSpec

  Util.mattr_accessor self, :params
  Util.mattr_accessor self, :schema

  class <<self

    def download(path, url)
      FileUtils.mkdir_p(File.dirname(path))
      
      File.open(path, 'w') do |f|
        json = open(url).string
        yaml = JSON.parse(json).to_yaml
        f.write(yaml)
      end
    end
  end

  def json_schema_fixture(resource=nil, method=nil)
    schema = 
      if defined?(@@schema)
        @@schema
      elsif defined?(Rails) && defined?(get)
        JSON.parse(get("/schema.json"))
      else
        path = "#{File.expand_path(".")}/spec/fixtures/schema.yml"
        YAML.load(File.read(path))
      end
    
    unless defined?(@@schema)
      schema = Util.symbolize_keys(schema)
    end

    @@schema = schema
    method   ? schema[method] : schema
  end

  def json_schema_params(resource, method, merge={})
    @@params ||= {}

    unless @@params[resource]
      schema             = json_schema_fixture(resource)
      @@params[resource] = json_schema_to_hash(schema)
    end

    params = @@params[resource]

    unless merge.empty?
      params = Util.deep_merge(params, merge)
      # validate_json_schema(resource, method, params)
    end

    Util.deep_dup(params)
  end

  def json_schema_to_hash(schema, prefix=[])
    return schema  unless schema.is_a?(Hash)
    
    schema.inject({}) do |memo, (key, value)|
      memo[key] = json_schema_value(key, value, prefix.dup)
      memo.delete(key)  unless memo[key]
      memo
    end
  end

  def json_schema_value(key, value, prefix)
    if !value.is_a?(Hash) || value[:optional]
      nil
    elsif value[:type] == 'string'
      json_schema_value_prefix(prefix) + key.to_s
    elsif value[:type] == 'integer'
      Random.rand(1_000_000)
    elsif value[:type] == 'object'
      json_schema_to_hash(value[:properties], prefix << key)
    else
      json_schema_to_hash(value)
    end
  end

  def json_schema_value_prefix(prefix)
    prefix = prefix.join(':')
    prefix = "#{prefix}:"  unless prefix.empty? 
    prefix.gsub(/^[^:]*:*/, '')
  end

  def validate_json_schema(resource, method, merge={})
    return  if RUBY_VERSION =~ /^1\.8\./

    webmock = webmock_fixture(resource)[method]
    schema  = schema_fixture(resource)[method]
    
    webmock = Util.deep_merge(webmock, merge)

    [ :request, :response ].each do |direction|
      validates = JSON::Validator.fully_validate(
        schema[direction],
        webmock[direction],
        :validate_schema => true
      )
      expect(validates).to eq([])
    end
  end
end
require "json"
require "json-schema"
require "open-uri"
require "yaml"

$:.unshift File.dirname(__FILE__)

require "json_schema_spec/tasks"
require "json_schema_spec/util"

module JsonSchemaSpec
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

  def json_schema(resource, method)
    schema = pick_json_schema
    schema = Util.symbolize_keys(schema)
    schema[:"#{resource}.json"][method]
  end

  def json_schema_params(resource, method, merge={})
    schema = json_schema(resource, method)
    params = json_schema_to_params(schema)
    params = Util.deep_merge(params, merge)

    validate_json_schema(resource, method, params)

    params = Util.deep_dup(params)
    [ params[:request], params[:response] ]
  end

  def json_schema_to_params(schema, prefix=[])
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
      json_schema_to_params(value[:properties], prefix << key)
    else
      json_schema_to_params(value)
    end
  end

  def json_schema_value_prefix(prefix)
    prefix = prefix.join(':')
    prefix = "#{prefix}:"  unless prefix.empty? 
    prefix.gsub(/^[^:]*:*/, '')
  end

  def pick_json_schema
    if defined?(Rails) && defined?(get)
      JSON.parse(get("/schema.json"))
    else
      path = "#{File.expand_path(".")}/spec/fixtures/schema.yml"
      YAML.load(File.read(path))
    end
  end

  def validate_json_schema(resource, method, params)
    return  if RUBY_VERSION =~ /^1\.8\./

    schema = json_schema(resource, method)

    [ :request, :response ].each do |direction|
      validates = JSON::Validator.fully_validate(
        schema[direction],
        params[direction],
        :validate_schema => true
      )
      expect(validates).to eq([])
    end
  end
end
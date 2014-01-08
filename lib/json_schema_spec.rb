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

    unless merge.empty?
      validate_json_schema(resource, method, params)
    end

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
    if !value.is_a?(Hash) || value[:optional] || value[:type] == 'null'
      nil
    elsif value[:enum]
      value[:enum].shuffle.first
    elsif value[:type] == 'array'
      [ json_schema_value(key, value[:items], prefix) ]
    elsif value[:type] == 'boolean'
      rand(2) == 1
    elsif value[:type] == 'integer'
      rand(1_000_000)
    elsif value[:type] == 'object'
      json_schema_to_params(value[:properties], prefix << key)
    elsif value[:type] == 'string'
      json_schema_value_prefix(prefix) + key.to_s
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
    if defined?(Rails)
      path       = "/schema.json"
      uri        = URI.parse(path)
      env        = Rack::MockRequest.env_for(uri, 'HTTP_ACCEPT' => 'application/json')
      params     = Rails.application.routes.recognize_path(path)
      controller = "#{params[:controller]}_controller".camelize.constantize
      endpoint   = controller.action(params[:action])

      JSON.parse(endpoint.call(env)[2].body)
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
        Util.stringify_keys(schema[direction]),
        Util.stringify_keys(params[direction]),
        :validate_schema => true
      )
      expect(validates).to eq([])
    end
  end
end